# Implementation Plan: Durable, Optimistic Background Image Uploads

**Spec:** ENG-10
**Date:** 2026-06-06
**Builds on:** ENG-4 (`a3eba02` "Add resilience to image uploader")

---

## Overview

Field arborists upload tree photos on weak cell connections. ENG-4 made the **S3 transfer** resilient (timeouts, retries, expiry refresh, multipart). But the most common remaining complaint — uploads that "stop at 100%" — is not an S3 problem. It's the **final association** step:

- The S3 object lands successfully, but the DB record that links it to an estimate/tree is still **coupled to the form's Save button** and is itself not fault-tolerant.
- **New quote** (`createEstimate/estimateForm.vue` → `taskForm.vue` → `file/actions/upload.vue`): each task holds `image.url`; the `TreeImage` is only created when the whole estimate is submitted via `POST /trees/bulk_create`. `getTreeImageAttributes()` (`estimateForm.vue:157`) **silently drops** any task whose `url` isn't ready. A hung/failed submit has no retry.
- **Existing quote** (`tree_images/actions/addNew.vue` → `file/actions/multiUpload.vue`): `uploadGuard` (`utils/uploadValidation.js`) **blocks Save** until every upload finishes, then fires one `POST /tree_images/create_from_urls`. One stuck-in-flight sibling blocks Save forever; a failed POST loses everything.
- All job state is **per-component and in-memory** (`UploadJob` instances owned by a Vue component). Navigate away, reload, or background the app and the job is gone — even though the S3 object may already exist.

**Approved scope (ENG-10):** make the *association* as resilient as ENG-4 made the *transfer*. Accept the file instantly, show a local preview, and have a **durable, global background queue drive both the S3 upload and the final association**, retrying indefinitely and surviving navigation/reload — decoupled from the Save button. Ship behind one new flexible `<app-uploader>` component, wired first into the two target flows: **new-quote tree images** and **add-images-to-existing-quote**.

---

## Approach

Promote upload state out of Vue components into a **global `UploadManager` singleton** backed by an **IndexedDB persistence adapter**. The manager owns all `UploadJob`s, survives route navigation, and on app boot **hydrates** persisted jobs and resumes any non-terminal work.

Extend `UploadJob` with two things ENG-4 lacked:

1. **A persisted `client_upload_id`** (stable across retries) and **write-through persistence** of every state transition.
2. **An `associating` phase** after S3 `success`: the job is not `done` until the file is *both* in S3 *and* linked to a DB record via an **idempotent** association endpoint (`find_or_create_by(client_upload_id:)`). Retryable errors retry **indefinitely** (capped backoff, online/offline aware); only truly fatal errors (auth/validation/4xx) stop.

Each job carries a **target descriptor** describing how to associate:

- **Existing quote** — target resolved at enqueue: `{ type: 'tree_image', estimate_id, tree_id }`. The placeholder is created immediately (see below); the URL fills in when S3 finishes.
- **New quote** — target starts **unresolved** (`{ type: 'tree_image', pending: true }`). The job uploads to S3 optimistically. On estimate submit we create the estimate + trees *without* images, get back ordered `tree_ids`, and **rewire** each job's target to its real `tree_id`. Placeholder creation + URL fill then complete in the background — even after the page navigates to the estimate detail view or is reloaded.

This is why IndexedDB pays off in both flows: association is now a durable background step keyed to a real persisted record, not a synchronous form payload.

### Placeholder-first (`TreeImage` exists before its S3 URL)

The `TreeImage` row is created **as soon as its target is resolved — before the S3 upload completes** — with a **null `image_url`** (a *pending* row). This means anyone viewing the estimate (not just the uploader) sees that an image is coming, and the record is durable even while S3 is still in flight. The uploader sees the real picture immediately via a local `objectURL`; other viewers see a pending placeholder until the URL lands (on their next estimate fetch — no realtime/websocket requirement). Consequences:

- A job runs **two decoupled async tracks**: (a) get the file into S3 (→ `url`), and (b) ensure the placeholder row exists (needs a resolved target). The job is `done` only once **both** are true and the URL has been written to the row. The endpoint is idempotent on `client_upload_id`, so creating the placeholder and later filling the URL are two safe calls to the same endpoint (a present `image_url` sets it; an absent one leaves it untouched — never overwrite a URL with nil).
- `image_url` is already **nullable** in the schema (`db/schema.rb:602`) — no migration needed for that. But the whole stack must tolerate nil without raising (Chunk 2 below).
- **Removing** a pending image must destroy its placeholder row (by id from the associate response). A *fatally* failed upload leaves a visible pending row that the user can retry/remove from the nav indicator; abandoned **new-quote** jobs never create a placeholder (target never resolved) so they leave only an orphaned S3 object, which is the accepted orphan case.

The new `<app-uploader>` component renders optimistic previews (`URL.createObjectURL(file)`, shown immediately, independent of S3) by subscribing to the manager's jobs for its target/group. The Save button no longer blocks on uploads.

---

## Discovery Notes & Pre-flight Decisions

Confirmed during exploration; these shape the implementation:

- **No true closed-app background upload.** JS does not run while the tab is closed, and iOS Safari supports neither Background Sync nor reliable persistent storage for non-installed web apps (script-writable storage can be evicted after ~7 days idle). IndexedDB buys **"resume automatically the moment the app is foregrounded/reopened, and retry forever"** — not "upload while fully closed." The plan and any user-facing copy must reflect this; do not promise closed-app uploads. `navigator.storage.persist()` should be requested best-effort but not relied on.
- **Cross-tab safety.** Two tabs could drive the same job. The `client_upload_id` idempotency key makes double-association harmless; additionally guard the *driver* with the Web Locks API (`navigator.locks.request`) where available, falling back to no lock (idempotency still protects correctness).
- **Stale multipart resume.** S3 multipart upload IDs and presigned URLs expire. A job resumed after a long gap must detect an expired/invalid multipart (`NoSuchUpload`/403) and **restart the file** (single-shot already re-presigns via `resolveTarget` in `uploadClient.js`). Add this branch to the multipart resume path.
- **`bulk_create` returns no IDs.** `trees_controller#bulk_create` currently renders `{ status: :ok }` and creates `TreeImage`s inline. It must (a) stop embedding image URLs and (b) return ordered `tree_ids` so the client can map task slot → real tree. This is a contract change to the new-quote submit path.
- **Existing presign endpoints stay.** `tree_images#new` (presigned POST) and `uploads/multipart_controller` are reused unchanged. Association is a *new, separate* endpoint — do not overload presign.
- **Idempotency column scope.** `client_upload_id` is a client-generated UUID. Uniqueness is global (a UUID), so a plain unique index is sufficient; `find_or_create_by(client_upload_id:)` is the upsert.
- **IndexedDB unavailable / private mode.** Some contexts throw on `indexedDB.open`. The persistence adapter must degrade to an in-memory adapter so uploads still work (just non-durable) rather than crashing the app.
- **Telemetry.** Keep ENG-4's `uploadTelemetry.js` no-op shim; add breadcrumbs for the new `associating`/`hydrate`/`resume` events. Wiring `@sentry/vue` remains out of scope.
- **Reactivity bridge.** `UploadManager` is plain JS; the global pending-uploads indicator needs reactive counts. Expose a small Vuex module (or a reactive Vue observable) that the manager updates, rather than making the whole manager reactive.

### Out of scope (follow-up)

- Migrating the *other* upload entry points (receipts, generic `files`, notes, single `imageUpload.vue`) — this ships the engine + two flows; the rest adopt `<app-uploader>` incrementally.
- Server-side S3 lifecycle rule to sweep never-associated (orphaned) objects. Noted; the user accepts orphaned S3 objects from abandoned forms.
- Persisting full new-quote **form state** (tasks/costs/notes). Without it, a reload mid-new-quote still loses the form; images alone resuming has limited value until the form is also draft-persisted.

### Confirmed decisions

1. **Association endpoint** — new dedicated, idempotent `POST /tree_images/associate`. `create_from_urls` stays in place until callers are migrated, then removed.
2. **Orphan TTL** — 7 days for unresolved/abandoned jobs in IndexedDB.
3. **Global indicator placement** — admin **nav bar** for now; reassess later.

---

## Chunks

Each chunk is independently implementable and verifiable. Backend (Chunk 1) and null-safety (Chunk 2) are pure-backend/frontend hardening testable without the queue; engine chunks (3–7) are testable without touching the forms; form integration (8) and UI (9) come last.

---

### ✅ Chunk 1 — Backend: idempotent association + `bulk_create` returns IDs

**Goal:** a retry-safe way to create a `TreeImage` and (separately) fill its S3 URL, plus tree IDs returned from bulk create.

**Changes:**
- Migration: add `client_upload_id:string` to `tree_images` + unique index. Nullable (legacy rows have none). `image_url` is **already** nullable — no change.
- `tree_images_controller#associate` (new action): params `{ estimate_id, tree_id (optional), image_url (optional), client_upload_id (required) }`. `authorize Estimate, :update?` (mirror `create_from_urls`). `find_or_create_by(client_upload_id:)` setting `tree`/`estimate_id`; **set `image_url` only when the param is present** (never overwrite an existing URL with nil — this lets the endpoint be called once to create the pending placeholder and again to fill the URL). When `tree_id` is blank, reuse the controller's existing `tree` "uncategorized/new" helper. Return the serialized `tree_image` (incl. its `id` so the client can later destroy it) and/or refreshed `estimate`.
- Serializer: add a derived `ready` (or `pending`) boolean to `TreeImageSerializer` = `object.image_url.present?`, so the frontend distinguishes pending vs ready without guessing.
- Route: `post '/associate', to: 'tree_images#associate', on: :collection` inside the existing `resources :tree_images` block.
- `trees_controller#bulk_create`: stop creating `TreeImage`s inline (remove the `tree_images_attributes` loop); collect created trees in order; `render json: { status: :ok, tree_ids: trees.map(&:id) }`.

**Verify:**
- `bundle exec rspec spec/controllers/tree_images_controller_spec.rb spec/controllers/trees_controller_spec.rb` (add specs): `associate` with no `image_url` creates a **pending** row (null url, `ready: false`); a second call **with** `image_url` and the same `client_upload_id` updates the **same** row (exactly one `TreeImage`, now `ready: true`); a later call with no `image_url` does **not** wipe the URL; `bulk_create` returns `tree_ids` in input order and creates no images.
- Pundit: unauthorized org cannot associate.

---

### ✅ Chunk 2 — Null-safety for pending (URL-less) `TreeImage`s

**Goal:** a `TreeImage` with `image_url == nil` never raises and never leaks a broken image into customer-facing output.

**Changes (Ruby):**
- `TreeImage#imgix_url` — guard: `return nil if url.blank?` before `url.gsub(...)`.
- `tree_images_controller#show` — if the resolved `image_url` is blank, render `head :no_content` (or a placeholder) instead of `URI.parse(nil)`.
- `quotes/pdf/_images.html.erb` — iterate only ready images: `estimate.tree_images.select { |i| i.image_url.present? || i.edited_image_url.present? }` (also feed the `each_slice` paging off the filtered set). Pending images must **not** appear in a generated quote.
- Sweep for any other `image_url`/`url`/`imgix_url` derefs in mailers/`lib`/`app/modules` surfaced during implementation; guard each.

**Changes (JS):**
- `tree_images/forms/imageThumb.vue` — when neither `edited_image_url` nor `image_url` is present, render a pending placeholder (spinner/"Uploading…") instead of a dead `<img>`.
- `tree_images/views/galleryModal.vue` + `views/markup.vue` — guard `displayedUrl`/editor open against a null URL (disable edit / show pending) so opening a pending image doesn't break the editor.
- `models/tree_image.model.js` `galleryDisplay` already passes nulls through — confirmed safe; consumers above handle the nulls.

**Verify:**
- RSpec: `TreeImage.new(image_url: nil).imgix_url` returns nil; `GET /tree_images/:id` for a pending row returns 204 (not 500); rendering `_images.html.erb` with a pending image in the set omits it and does not raise.
- Manual: an estimate containing a pending image renders the grid (placeholder shown), opens the gallery without a broken editor, and a generated quote PDF excludes the pending image.

---

### ✅ Chunk 3 — Persistence adapter (IndexedDB + in-memory fallback)

**Goal:** a storage layer the manager can write through, with graceful degradation.

**Changes:**
- `app/javascript/services/upload/persistence.js`: async interface `all()`, `get(id)`, `put(record)`, `patch(id, partial)`, `delete(id)`, `purgeOlderThan(ms, predicate)`.
- IndexedDB impl: one object store `upload_jobs` keyed by `id`, schema-versioned. Record = `{ id, clientUploadId, blob (File/Blob), filename, type, bucketName, presignPath, compress, status, progress, multipart: { uploadId, key, parts }, target, attempts, createdAt, updatedAt }`.
- On `indexedDB.open` failure/throw, transparently return an in-memory `Map`-backed adapter (non-durable).
- Best-effort `navigator.storage.persist()` on init.

**Verify:**
- Plain-JS unit tests under `node --test` (matches ENG-4 convention) using a fake-indexeddb shim (or adapter-level tests against the in-memory impl): round-trip a record incl. a `Blob`; `patch` merges; `purgeOlderThan` removes only matching/old records; forcing `open` to throw yields the in-memory adapter and still satisfies the interface.

---

### ✅ Chunk 4 — `UploadJob`: client id, write-through, indefinite retry

**Goal:** jobs persist their state and retry retryable failures forever; fatal still stops.

**Changes (to `services/UploadJob.js`):**
- Add `clientUploadId` (UUID, persisted; reused on resume).
- `_setState` also calls `adapter.patch(this.id, { status, progress, error, multipart, ... })` (debounced for progress).
- Replace the hard `MAX_ATTEMPTS → fatalError` behaviour **for retryable errors** with indefinite backoff (exponential, capped at e.g. 60s, jittered). Keep `UploadFatal` → `fatalError` (no retry) for auth/validation/non-retryable 4xx.
- Online/offline: on `offline` → `pause()`; on `online` → auto-resume retryable/paused jobs (the manager wires the listeners — Chunk 5 — but the job exposes resume-from-current-state).
- Multipart resume: if init/complete/part returns `NoSuchUpload`/expired, clear `multipart` state and restart as a fresh upload.

**Verify:**
- `node --test`: with a stubbed `uploadClient`, a job that returns retryable errors keeps scheduling retries (assert backoff grows, capped) and never reaches `fatalError`; a `UploadFatal` reaches `fatalError` immediately. Every transition produces an `adapter.patch`. An expired-multipart response triggers a clean restart.

---

### ✅ Chunk 5 — `UploadManager` singleton + hydration

**Goal:** one global owner of all jobs that survives navigation and resumes on boot.

**Changes:**
- `app/javascript/services/upload/uploadManager.js`: singleton holding `Map<id, UploadJob>`. API: `enqueue({ file, target, bucketName, presignPath, compress }) → job`, `get(id)`, `jobsForTarget(predicate)`, `resolveTarget(id, target)` (rewire + persist + create placeholder + kick URL-fill), `remove(id)`, `retry(id)`, `hydrate()`, `subscribe(fn)`.
- `hydrate()`: load adapter records, reconstruct `UploadJob`s, resume any non-terminal status (respecting online state). Run `purgeOlderThan(TTL, unresolvedOrAbandoned)` and delete `done` records.
- Wire global `online`/`offline` listeners once here (replaces the per-component listeners in `uploadList.vue`).
- Web Locks guard around driving a job where `navigator.locks` exists.
- Initialize from the admin pack boot (`packs/admin.js`) so it hydrates once per session; expose to components (e.g. `Vue.prototype.$uploads` or import).

**Verify:**
- `node --test` against the in-memory adapter: enqueue → persisted; simulate "reload" by constructing a fresh manager over the same adapter and calling `hydrate()` → non-terminal jobs resume, `done` records are purged, expired unresolved jobs are TTL-purged. `resolveTarget` resolves an unresolved job's target and kicks placeholder creation.
- Manual: start an upload, navigate between admin routes — job keeps running (visible via Chunk 9 indicator or console breadcrumbs).

---

### ✅ Chunk 6 — Two-track association (placeholder-first) in the job

**Goal:** the `TreeImage` row exists as soon as the target is known (pending, null URL); the job is `done` only once the row exists **and** its URL is filled — both idempotent and retried indefinitely.

**Changes:**
- The job tracks two independent flags: `s3Url` (set when S3 finishes) and `placeholderId` (set when the placeholder row exists). Both feed a single `POST /tree_images/associate` keyed on `client_upload_id` via the retrying client (reuse `withRetry`/Rails client, indefinite for retryable).
  - **Ensure-placeholder track:** as soon as `target` is resolved, call `associate` **without** `image_url` → records `placeholderId`. (Existing-quote: target resolved at enqueue, so this fires immediately, in parallel with the S3 upload. New-quote: fires when `resolveTarget` runs at submit.)
  - **Fill-URL track:** the S3 upload runs regardless of target. Once **both** `s3Url` and `placeholderId` exist, call `associate` **with** `image_url` → row becomes ready → `done`.
- Statuses: `idle → compressing → preparing → uploading → finalizing → (s3 done)`; orthogonally `pendingAssociation` until placeholder exists; terminal `done` when the URL is written. A job with target unresolved sits in `awaitingTarget` after S3. Update `IN_PROGRESS` sets and `uploadGuard` so `done` (not S3 `success`) is the terminal happy state; pending-but-uploading is not an error.
- Removing a job whose `placeholderId` is set issues `DELETE /tree_images/:id` so no dangling pending row is left.

**Verify:**
- `node --test`: a resolved-target job creates the placeholder before S3 completes (assert `associate` called with no `image_url` first), then fills the URL after S3 (second `associate` with `image_url`), reaching `done`; ordering of the two tracks doesn't matter (S3-first and placeholder-first both converge to one `done`, one row). A retryable failure on either track retries to success. An unresolved-target job creates no placeholder and advances only after `resolveTarget`. Remove after placeholder issues a `DELETE`.
- Integration (manual): kill the network right at 100%, restore it → URL fill completes on its own, no duplicate row (verify via `client_upload_id`).

---

### ✅ Chunk 7 — `<app-uploader>` flexible component

**Goal:** one component for single/multi, optimistic preview, manager-backed.

**Changes:**
- `app/javascript/components/file/uploader.vue` (new), globally registered as `app-uploader` in `packs/admin.js`. Props: `target` (descriptor or `{ pending: true }`), `multiple`, `accept`, `bucketName`, `presignPath`, `compress`, `value`. On file select → `manager.enqueue(...)` per file; render previews from `manager.jobsForTarget(...)` filtered by a per-instance `group` id. Optimistic thumb via `URL.createObjectURL(file)` shown immediately. Per-item retry/remove. Emits `input` with the list of `{ id, clientUploadId, status, url }` and exposes a `pending`/`failed` summary.
- Reuse/keep `uploadItem.vue` presentation; refactor `uploadList.vue`/`actions/*` to delegate to the manager (or mark them legacy). Design-system tokens for any new styling (no hardcoded colours; replace `#dc3545` with `--danger`, spinner `--main-color`, etc.).

**Verify:**
- Storybook-less manual harness page (or mount in a scratch route): selecting files shows instant previews before S3 finishes; removing cancels + deletes the job; component survives unmount/remount without losing the manager's jobs.

---

### ✅ Chunk 8 — Wire the two target flows

**Goal:** both target flows use `<app-uploader>` + the durable queue; Save never blocks; pending rows appear for all viewers.

**Changes:**
- **Existing quote** (`tree_images/actions/addNew.vue`): replace `app-multi-image` with `<app-uploader :target="{ type:'tree_image', estimate_id, tree_id }">`. Because the target is resolved, each added file creates a **pending `TreeImage` immediately** (Chunk 6) — so a second viewer sees it. Remove the `uploadGuard`-blocks-Save behaviour; Save just closes the sidebar (jobs continue in background). Refresh the estimate via `EventBus ESTIMATE_UPDATED` when placeholders/URLs land (manager event → re-fetch, or optimistic insert). Keep `create_from_urls` only until fully migrated.
- **New quote** (`createEstimate/taskForm.vue` + `estimateForm.vue`): each task's image slot uses `<app-uploader :target="{ pending:true }">` and records the job id. On submit: `POST /estimates` → costs → `POST /trees/bulk_create` (no `tree_images_attributes`) → read `tree_ids` → for each task with a job, `manager.resolveTarget(jobId, { estimate_id, tree_id })` (this creates the placeholder + kicks URL fill) → navigate to the estimate. Delete the silent-drop `getTreeImageAttributes` path. Assert `tree_ids.length` matches the task count before resolving (guards slot→tree mismaps).

**Verify (the core acceptance test):**
- New quote, throttled network: add images, submit immediately → estimate is created, page navigates; the estimate shows **pending** images right away (for the uploader *and* a second browser/session), which fill in as S3 completes; reload the estimate page mid-upload → uploads resume and URLs fill; final `TreeImage` rows match, no duplicates, no null-exception anywhere.
- Existing quote: add images, hit Save while still uploading → sidebar closes, pending images show on the estimate immediately and become viewable once their URL lands; failed fill auto-recovers; one stuck file no longer blocks the others.
- Abandon a new-quote form (never submit) → no `TreeImage` rows created (target never resolved); jobs TTL-purged later; only an orphaned S3 object remains (accepted); no console errors.

---

### ✅ Chunk 9 — Global pending/failed indicator + cleanup polish

**Goal:** background work is visible; storage stays bounded; privacy on shared devices.

**Changes:**
- Small Vuex module (or reactive observable) fed by `manager.subscribe` exposing `{ active, failed }` counts; a badge in the **admin nav bar** (confirmed placement) linking to a list of in-flight/failed uploads with retry/remove.
- Logout clears the `upload_jobs` store (and aborts in-flight jobs).
- Confirm TTL purge + `done`-record purge run on hydrate and periodically.

**Verify:**
- Manual: badge increments on enqueue, decrements on `done`, shows failures with working retry; logout empties IndexedDB (`Application → IndexedDB` in devtools); abandoned jobs disappear after TTL (test with a short TTL override).

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| iOS evicts IndexedDB / no closed-app background | Don't promise closed-app upload; resume-on-foreground + indefinite retry; best-effort `storage.persist()`. |
| Duplicate `TreeImage`s from retries / multi-tab | `client_upload_id` unique + `find_or_create_by`; Web Locks driver guard. |
| New-quote target rewiring mismaps slot→tree | `bulk_create` returns ordered `tree_ids`; assert array length matches task count before resolving; carry an explicit slot index. |
| Orphaned S3 objects from abandoned forms | Accepted by product; TTL-purge client jobs; note server-side lifecycle sweep as follow-up. |
| Expired multipart on long-delayed resume | Detect `NoSuchUpload`/403 → restart file. |
| IndexedDB blob bloat | Purge on `done`; TTL on unresolved; compression already caps ~1 MB. |
| Pending (null-URL) `TreeImage` raises somewhere unaudited | Chunk 2 null-safety sweep + `imgix_url`/`show` guards + quote PDF filter; `ready` flag in serializer; grep all `image_url`/`url`/`imgix_url` derefs during impl. |
| Dangling pending rows from fatally-failed uploads | Visible/retryable in nav indicator; remove issues `DELETE`; existing-quote only (new-quote creates rows only after submit). |

---

## Verification Summary

- **Unit (`node --test`)**: persistence adapter; `UploadJob` retry/persistence/two-track placeholder+URL association; `UploadManager` hydrate/resume/purge/resolveTarget.
- **RSpec**: `associate` idempotency (pending row then URL fill, never overwrite URL with nil) + authorization; `bulk_create` returns ordered IDs and creates no images; null-safety (`imgix_url` nil, `show` 204, quote PDF excludes pending).
- **Manual acceptance**: throttled-network new-quote submit-then-background-finish with **pending images visible to a second viewer**; existing-quote non-blocking Save; mid-upload reload resumes and fills URLs; no duplicate rows; no null exceptions on an estimate/gallery/quote-PDF containing a pending image; logout clears storage.
