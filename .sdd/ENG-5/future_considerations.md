# Future Considerations: Items Deferred from ENG-5 (Rails 8 Upgrade)

**Spec:** ENG-5 (companion document)
**Date:** 2026-05-08

These were intentionally excluded from the Rails 6 → 8 upgrade to keep its scope contained. Each is a candidate for its own ticket once the Rails 8 + Solid Queue work is stable.

---

## 1. Migrate `secrets.yml` + Figaro → Rails encrypted credentials

**Status today:** `config/secrets.yml` exists (deprecated since Rails 7.2), and `config/application.yml` (Figaro) is the actual runtime secret store. `Rails.application.secrets` accessor is removed in Rails 8 — confirmed unused in this codebase before the 7.2 → 8.0 step.

**Why defer:** Figaro works fine. Migrating means moving every `Figaro.env.X` callsite to `Rails.application.credentials.X`, encrypting `config/credentials.yml.enc`, distributing `master.key` via Capistrano's linked-files pattern, and updating CI to inject the master key. It's a multi-day project on its own and provides no functional benefit — only convention alignment.

**Effort estimate:** ~2 days. Touches every secret reference (~30 callsites across initializers, mailers, AWS config).

**Trigger to revisit:** when adding a new secret category (e.g. a third-party API key) makes the Figaro → credentials inconsistency painful, or when onboarding a new dev requires explaining "we have two secret systems."

---

## 2. Switch Sprockets → Propshaft

**Status today:** Sprockets 4 (post-upgrade) handles `app/assets/stylesheets/` (54 SCSS files), the legacy `app/assets/javascripts/`, and image precompilation. Sass via `sass-rails` (or `sassc-rails` if we swap during the upgrade).

**Why defer:** Propshaft is Rails 8's default for *new* apps because it's simpler — no SCSS preprocessing, no JS transformation, just digesting and serving files. For an existing app with 54 SCSS files and CoffeeScript still in `app/assets/javascripts/`, switching means migrating the SCSS pipeline to either dartsass-rails or cssbundling-rails (and the CoffeeScript to plain JS, or eliminating it entirely). High disruption for low ongoing benefit.

**Effort estimate:** ~3-5 days. Forces a CSS pipeline decision and a CoffeeScript decision in the same ticket.

**Trigger to revisit:** when sprockets manifest issues block a deploy, or when migrating the `app/assets/` content to Webpacker/Shakapacker entirely (consolidating to one frontend pipeline).

---

## 3. Replace turbolinks → Turbo (Hotwire)

**Status today:** `gem 'turbolinks'` 5.2.1 is in use. `data-turbolinks-track` attributes appear on stylesheet/javascript tags in `app/views/layouts/{application,white_label,onboarding_page}.html.erb`. The onboarding pack registers a `turbolinks:load` listener and uses the `vue-turbolinks` adapter (`app/javascript/packs/onboarding.js`).

**Why defer:** turbolinks 5 still works on Rails 8. Switching to Turbo means: (a) replacing the gem, (b) updating layout attributes (`data-turbo-track` instead of `data-turbolinks-track`), (c) replacing `vue-turbolinks` with a Turbo-aware Vue mount strategy (no maintained adapter exists), and (d) auditing every place we depend on `turbolinks:load` event timing. Onboarding pack is the riskiest piece because it's public-facing.

**Effort estimate:** ~2-3 days, mostly testing.

**Trigger to revisit:** when adopting Turbo Frames or Turbo Streams for a feature would simplify a Vue-heavy admin page (e.g. live updating a list without a full SPA round-trip), or when the unmaintained `vue-turbolinks` adapter actually breaks.

---

## 4. Adopt Rails 8 Dockerfile + Kamal deployment

**Status today:** Capistrano 3.19 → Passenger → nginx on a single EC2 instance (50.17.61.15, per `config/deploy.rb`). MySQL on the same host. delayed_job (now Solid Queue) on the same host.

**Why defer:** Replacing Capistrano with Kamal is a deployment overhaul, not a code change. It would mean: provisioning Docker on the host, building a production image (`Dockerfile` ships in Rails 8 generators), wiring Kamal config (`config/deploy.yml`), arranging zero-downtime deploys, and probably moving Solid Queue / database to separate containers. Worth doing eventually for ergonomics, but it's a separate project entirely.

**Effort estimate:** ~1-2 weeks. Coordination with infra (DNS, secrets, monitoring) outweighs the code diff.

**Trigger to revisit:** when adding a second app server (horizontal scale), when the manual systemd unit setup for Solid Queue (per ENG-5 step 7) becomes painful on a second/third deploy host, or when Capistrano gem maintenance lapses.

---

## Other items noticed during ENG-5 exploration but not part of the deferred list

These are smaller observations worth a follow-up ticket eventually, but they're not direct alternatives to anything in ENG-5:

- **`twitter-bootstrap-rails` 5.0.0 is unmaintained** — last release 2018. If it breaks during the upgrade, ENG-5 will remove it. If it survives the upgrade, file a follow-up to remove it anyway.
- **`coffee-rails`, `uglifier`, `jquery-rails`** — pre-Webpacker assets in `app/assets/javascripts/`. Probably mostly dead code; an audit + removal ticket would meaningfully shrink the asset surface.
- **CoffeeScript files in `app/assets/javascripts/`** — block both a Propshaft migration and a "single frontend pipeline" goal. Inventory + JS rewrite.
- **`active_model_serializers` 0.10.x** — community-maintained, lags Rails majors. If Rails 9 breaks it, evaluate `jbuilder` or `Rails 7+`'s built-in JSON rendering.
- **No CI configuration found** in `.github/workflows/`, `.circleci/`, or `.travis.yml`. Standing up GitHub Actions running `bundle exec rspec` would dramatically de-risk every future upgrade. **Strongly recommended before starting ENG-5 step 0** — not after.
- **`config/secrets.yml`** — once `Rails.application.secrets` is removed in Rails 8, this file is inert. Can be deleted during ENG-5 step 8 or as its own follow-up.
