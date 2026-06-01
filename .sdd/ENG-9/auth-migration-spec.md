# Auth Migration Spec — Cookie Auth → Header-Based Token Auth

**Status:** Draft / ready to implement
**Author:** (fill in)
**Created:** 2026-06-01
**Target:** Implement over the coming days

---

## 1. Motivation

The current auth scheme is cookie-based, which forces us to run CSRF protection,
and that protection has been causing real, unreproducible production failures.
We have **temporarily disabled CSRF** (`skip_forgery_protection` in
`ApplicationController`, added 2026-06-01) as a stopgap. This migration removes
the *root condition* that required CSRF in the first place, so we can leave it
off permanently and honestly.

### Problems with the current scheme

1. **Ambient cookie auth ⇒ CSRF is mandatory.** Identity is read from a cookie
   the browser attaches automatically (`UserHelper#current_user` reads
   `cookies[:session_token]`), which is the precondition for CSRF attacks.
2. **CSRF token and auth live in cookies with opposite lifetimes.** The CSRF
   token lives in the ephemeral `_bigtrees_session` cookie (`:cookie_store`, no
   `expire_after` → browser-session scoped), while auth lives in
   `cookies.permanent[:session_token]` (~20 years). Users stay logged in long
   after their CSRF session lapses → intermittent "Can't verify CSRF token
   authenticity" errors that we can't reproduce in fresh test sessions.
3. **FE/BE coordination friction.** Threading the CSRF token from a meta tag
   into a long-lived SPA (read once at boot, never refreshed —
   `axiosMixin.js:78`, `axiosFunctions.js:17`) is brittle.
4. **Weak credential hygiene** (orthogonal but worth fixing in the same pass):
   `session_token` is a single permanent column on `Arborist`
   (`before_create :set_session_token`, `SecureRandom.hex`), **never expires,
   never rotates, cannot be revoked per-device**, and the cookie is **not
   `HttpOnly`** (already JS-readable today).

## 2. Goals

- **G1.** Move the auth credential from an automatically-sent cookie to an
  explicit `Authorization` header. This removes the CSRF attack class entirely
  (a forged cross-site request cannot set the header).
- **G2.** Replace the single permanent `session_token` column with a proper
  `sessions` table supporting **expiry, rotation, revocation, and multi-device**.
- **G3.** Add **XSS hardening (CSP)** since the token becomes JS-accessible.
- **G4.** Remove CSRF machinery permanently once header auth is the only path.
- **G5.** Zero forced logouts for active users during rollout (backwards-compatible).

## 3. Non-goals

- OAuth / SSO / third-party identity providers.
- Changing the Devise password-reset flow (stays as-is).
- Changing the org-scoping mechanism (`X-ORGANIZATION-ID` header /
  `OrganizationContext`) beyond what auth requires.
- 2FA (can be layered on the new `sessions` table later).

## 4. Current-state reference (files of record)

| Concern | Location |
| --- | --- |
| Sign in / out, `current_user` | `app/helpers/user_helper.rb` (`UserHelper`) |
| Token column + generation | `app/models/arborist.rb` (`set_session_token`) |
| Login / `/authenticate` / logout | `app/controllers/sessions_controller.rb` |
| Auth wiring + org context | `app/controllers/application_controller.rb` |
| CSRF disabled (temp) | `app/controllers/application_controller.rb` (`skip_forgery_protection`) |
| Session cookie config | `config/initializers/session_store.rb` |
| Frontend request layer | `app/javascript/mixins/axiosMixin.js`, `app/javascript/mixins/axiosFunctions.js` |
| SPA layout / meta CSRF tag | `app/views/layouts/admin_vue.html.erb` |
| CORS | `config/initializers/cors.rb` (currently localhost origins only) |
| SSL | `config/environments/production.rb` (`force_ssl` currently commented out) |

## 5. Target architecture

### 5.1 Data model — `sessions` table

```
sessions
  id            bigint pk
  arborist_id   bigint  fk -> arborists, indexed
  token_digest  string  # SHA-256 of the opaque token; UNIQUE index. Never store the raw token.
  expires_at    datetime, indexed
  last_used_at  datetime
  revoked_at    datetime null
  user_agent    string null
  ip            string null
  created_at / updated_at
```

- **Raw token** = `SecureRandom.urlsafe_base64(32)`, returned to the client
  **once** at login. We persist only `token_digest = Digest::SHA256.hexdigest(raw)`
  so a DB leak does not expose live credentials.
- A session is **valid** iff `revoked_at IS NULL AND expires_at > now`.
- `Arborist has_many :sessions`. The legacy `arborists.session_token` column is
  retained read-only during rollout, dropped in the final phase.

### 5.2 Backend auth flow

- New `Authentication` concern (replaces the cookie reads in `UserHelper`):
  - Reads `Authorization: Bearer <raw>` → digest → look up valid `Session` →
    set `current_user` and touch `last_used_at`.
  - No valid session ⇒ `current_user` is nil ⇒ JSON `401` (not a redirect) for
    API requests.
- `SessionsController`:
  - `create` (login): validate email/password/memberships (unchanged), create a
    `Session`, return `{ token:, expires_at:, ...AuthSerializer }` in the JSON
    **body**. No `Set-Cookie`.
  - `authenticate` (bootstrap): identifies the user from the header instead of
    the cookie; same response shape as today.
  - `destroy` (logout): revoke the current session row (`revoked_at = now`).
  - **`refresh`** (new): see §5.4.
- `set_organization` / `OrganizationContext` continue to work — they only need
  `current_user`, which now comes from the header.

### 5.3 Frontend

- On login success, store the token (see §5.5) and set
  `axios.defaults.headers.common['Authorization'] = 'Bearer ' + token`.
- **Remove** `withCredentials: true`, the `X-CSRF-Token` header, and the meta-tag
  read from `axiosMixin.js` and `axiosFunctions.js`.
- Add a **response interceptor**: on `401`, clear the stored token and route to
  login (and, if refresh tokens are used, attempt a silent refresh first).
- App boot: if a stored token exists, set the header and call `/authenticate`;
  on `401`, send to login.

### 5.4 Token lifetime & refresh

**Recommended (pragmatic for our size):** a single opaque session token with a
**rolling 14-day expiry** — `last_used_at`/`expires_at` slide forward on use
(throttled to ~once/hour to avoid a write per request). Logout and an admin
"revoke sessions" action set `revoked_at`. Simple, fully server-revocable, good
enough for an internal admin tool.

**Alternative (if we want short-lived bearer tokens):** 15-min access token +
long-lived refresh token via a `POST /sessions/refresh`. More moving parts;
documented here but **not** recommended for v1.

### 5.5 Token storage on the client — decision required

| Option | Survives reload | XSS exposure | Notes |
| --- | --- | --- | --- |
| **`localStorage`** (recommended v1) | yes | readable by any XSS | Simplest; matches our current XSS exposure (token is already JS-readable). Pair with strict CSP. |
| In-memory only (Vuex) | no | not persisted | Most XSS-resistant but logs users out on refresh unless paired with a refresh cookie. |
| Access token in memory + refresh token in `HttpOnly; SameSite=Strict` cookie | yes | access token not persisted | Best security, but the refresh cookie reintroduces a (narrow) CSRF surface on the refresh endpoint only. |

**Recommendation:** `localStorage` + CSP for v1 (no regression vs. today, much
simpler), revisit the hybrid model post-migration if we harden further.

### 5.6 Security hardening (do together with the transport change)

- **Enable `force_ssl`** in `config/environments/production.rb` (currently
  commented out). A bearer token in a header over plain HTTP is sniffable.
- **Add a Content-Security-Policy** (`config/initializers/content_security_policy.rb`)
  — this is the primary defense now that the token is JS-readable. Lock
  `script-src` to self + known hosts; no inline scripts where avoidable.
- **Remove CSRF entirely** once cookie auth is gone: drop the temporary
  `skip_forgery_protection` and set
  `config.action_controller.default_protect_from_forgery = false` (CSRF is moot
  with no ambient credential).
- Review **CORS** (`config/initializers/cors.rb`): with header auth, `credentials:
  true` is no longer needed; lock `origins` to the real admin host(s).

## 6. Rollout — phased & backwards-compatible

Each phase is independently shippable. The dual-accept window (Phase 1–3) means
no active user is logged out.

- **Phase 0 — Schema & model.** Add `sessions` table + `Session` model +
  `Arborist has_many :sessions`. No behavior change. Ship.
- **Phase 1 — BE dual-read.** Auth concern accepts **either** the legacy
  `session_token` cookie **or** `Authorization` header. Login creates a `Session`
  row *and* still sets the cookie. Logout revokes the row *and* clears the cookie.
  Ship + verify in prod (both paths green).
- **Phase 2 — FE switch.** SPA stores the returned token, sends the header, drops
  `withCredentials`/CSRF. Cookie still accepted by BE as fallback. Ship behind a
  quick rollback (revert FE only if needed).
- **Phase 3 — Drop cookie path.** Remove cookie reads/writes from the BE; header
  is the only accepted credential. Remove CSRF machinery + temp
  `skip_forgery_protection`. Enable `force_ssl`, add CSP, tighten CORS.
- **Phase 4 — Cleanup.** Drop the `arborists.session_token` column, delete dead
  CSRF/cookie code, update `CLAUDE.md` auth notes.

## 7. Task breakdown (tickets)

1. Migration: create `sessions` table (+ indexes on `token_digest` unique,
   `arborist_id`, `expires_at`).
2. `Session` model: validations, `valid?`/scopes (`active`), digest helpers,
   `generate!(arborist, request)` returning the raw token.
3. `Authentication` concern: header parsing, dual-read fallback, `current_user`,
   `last_used_at` touch (throttled), JSON 401 for unauthenticated API calls.
4. `SessionsController`: update `create`/`authenticate`/`destroy`; add `refresh`
   if we adopt the alternative model.
5. FE: token storage util, axios header injection, 401 interceptor, boot flow,
   remove CSRF/`withCredentials` (`axiosMixin.js`, `axiosFunctions.js`).
6. CSP initializer + `force_ssl` + CORS tightening.
7. Remove cookie path + CSRF (Phase 3).
8. Drop legacy column + docs (Phase 4).

## 8. Testing strategy

- **Model specs:** session validity (active/expired/revoked), digest never
  stores raw token, rolling-expiry update logic.
- **Request specs:** header auth happy path; expired/revoked/missing/garbage
  token → 401; dual-read fallback during Phases 1–2; logout revokes; org header
  still resolves `current_user`.
- **Regression:** Pundit policies and `OrganizationContext` unaffected.
- **Frontend:** interceptor attaches header; 401 routes to login and clears
  token; reload restores session from storage.
- **Manual prod-like check:** long-parked tab and mobile Safari (the population
  that surfaced the original CSRF bug) — confirm no spurious logouts/errors.

## 9. Rollback plan

- Phases 0–1 are additive; revert is a normal deploy rollback.
- Phase 2 (FE) is the riskiest: because BE still accepts the cookie, reverting
  only the FE bundle restores the working cookie flow.
- Phase 3+ removes the cookie path — do **not** enter Phase 3 until Phase 2 has
  soaked in prod with header auth confirmed healthy (watch Sentry for 401 spikes).

## 10. Open decisions (resolve before Phase 2)

- [ ] Token storage: `localStorage` (recommended) vs. memory+refresh-cookie hybrid.
- [ ] Token lifetime: 14-day rolling (recommended) vs. short access + refresh.
- [ ] Multi-device: keep all sessions, or cap N per user / "log out other devices"?
- [ ] Production host list for the tightened CORS `origins`.

## 11. Alternative considered — keep cookies, do CSRF "properly"

We could instead keep `HttpOnly; Secure; SameSite=Strict` cookie auth and fix CSRF
with a token-refresh endpoint + 422 retry (the quick fix discussed). This is a
valid, arguably more XSS-resistant design. **We rejected it for v1** because (a)
our current cookie is *not* `HttpOnly`, so we aren't getting that benefit today;
(b) it keeps the FE/BE coordination friction; and (c) header auth lets us delete
CSRF entirely rather than maintaining a refresh shim. Documented so the trade-off
is explicit and revisitable.
