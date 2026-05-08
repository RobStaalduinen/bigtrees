# Implementation Plan: Rails 6 → Rails 8 Upgrade and Solid Queue Adoption

**Spec:** ENG-5
**Date:** 2026-05-08

---

## Context

The app is on Rails 6.0.6.1 (`Gemfile:5`), three minor versions and one major version behind current. Rails 6.0 has been out of security support since June 2023; Rails 6.1 since October 2024. Staying here means accumulating CVE risk, blocking modern gem versions, and making every future "small" upgrade harder. We also want Solid Queue (Rails 8's first-party background job backend) so we can retire delayed_job, which today runs as a single daemon kept alive by a 3-hour cron restart (`config/schedule.rb:25-27`) — fragile and operationally weird.

Two things make this upgrade tractable:

1. **The job surface is essentially empty.** No `app/jobs/`, no `.delay.` callsites, no `Delayed::Job.enqueue` calls, no `deliver_later` calls. The `delayed_jobs` table is in the schema (`db/schema.rb`) but does not get used at runtime. Solid Queue migration is "swap the adapter and the worker process" with zero application code changes.
2. **Ruby is already at 3.3.1** (`.ruby-version`), well above Rails 8's floor (3.2). No Ruby bump needed.

The hardest piece is **Webpacker** (`Gemfile:64`, `@rails/webpacker@4.3.0` in `package.json:3`). Webpacker is gone in Rails 7+. We're going to Shakapacker — the community fork that's actually a drop-in replacement and supports Vue 2 — so all three packs (`admin.js`, `onboarding.js`, `property_management.js`) keep their existing structure.

## Decisions Locked In

(From intake — these aren't being re-litigated.)

- **Upgrade path:** incremental, one Rails minor per PR — 6.0 → 6.1 → 7.0 → 7.1 → 7.2 → 8.0.
- **Frontend:** Webpacker → Shakapacker. Vue 2 stays. No Vue 3 migration in this work.
- **Solid Queue scope:** adapter swap only. Single DB (no separate `queue` connection). Mailers stay on `.deliver_now` for now.
- **Deferred to `future_considerations.md`:** Rails encrypted credentials, Sprockets → Propshaft, turbolinks → Turbo/Hotwire, Dockerfile/Kamal deployment.

## Approach

Each Rails minor bump is its own PR with the same shape — bump the Gemfile pin, run `rails app:update`, hand-merge config diffs, add the matching `new_framework_defaults_X_Y.rb`, fix breakages until `bundle exec rspec` is green, deploy, soak for ~2 days in production, then bump `config.load_defaults` in a follow-up PR before starting the next minor.

The ordering is deliberate:

```
0. Pre-flight hygiene (still on 6.0)
1. Rails 6.0 → 6.1
2. Webpacker → Shakapacker (still on 6.1 — must precede 7.0)
3. Rails 6.1 → 7.0
4. Rails 7.0 → 7.1
5. Rails 7.1 → 7.2
6. Rails 7.2 → 8.0
7. Install Solid Queue, swap adapter, retire delayed_job
8. Cleanup (drop delayed_jobs table, remove dead gems/binstubs)
```

**Why Shakapacker before 7.0, not at 7.0:** Shakapacker 7+ supports Rails 6.0+ and is API-compatible with Webpacker 5. Doing it as its own PR on Rails 6.1 means the Webpacker → Shakapacker diff is reviewed in isolation, not bundled into the Rails 7.0 upgrade where everything is already moving. If the Shakapacker swap breaks, we revert one PR — not a Rails major bump.

**Why one PR per minor:** Rails framework defaults change at minor boundaries, and `config.load_defaults` is the single biggest source of "works locally, breaks in prod" problems. Bumping it independently from the gem version (i.e. ship the gem bump on the previous defaults, soak, then bump defaults) gives us a clean rollback for each.

## Pre-Flight Decisions & Discovery Notes

These were confirmed during exploration and shape the plan:

- **`config.load_defaults` is currently absent from `config/application.rb`.** That means we're effectively running on Rails 5.2 defaults (the framework-built-in fallback), not 6.0. The first thing to do on the 6.0 → 6.1 PR is *add* `config.load_defaults 6.0` explicitly, soak it, then start moving forward. Otherwise the first bump silently changes a dozen behaviors we don't currently rely on.
- **`active_model_serializers` is at 0.10.15** (`Gemfile:75`, locked at 0.10.15). The 0.10 line is community-maintained and known to be flaky against Rails 7.1+. We do not switch serializers in this work — we just verify each minor compiles. If it breaks at a specific Rails version, the fallback is to pin to a known-good fork (community `0-10-stable` branch) rather than rewrite serializers across `app/serializers/`.
- **`twitter-bootstrap-rails` 5.0.0** (`Gemfile:43`) is a long-unmaintained gem. It has not had a release since 2018 and pulls in `less-rails`/`therubyracer` historically. Verify it boots on each Rails minor; if it breaks at 7.x, the contained scope is "remove the gem and inline the few generators it provided." Do NOT pull this into the upgrade — file a follow-up.
- **`mini_racer` 0.16.0** (`Gemfile:44`) is fine on Ruby 3.3 + Rails 8. No action.
- **Custom `autoload_paths` in `config/application.rb:14-18`** add `lib/` and its subdirs to both autoload and eager_load. Zeitwerk (Rails 6's default) tolerates this if `lib/` is structured in a Zeitwerk-compatible way (one constant per file matching the path). Verify on the 6.1 PR by running `bin/rails zeitwerk:check`. If it fails, the fix is to either (a) restructure offending files or (b) move them out of autoload paths and `require` them explicitly.
- **`config/secrets.yml` exists** alongside Figaro. We are NOT migrating to encrypted credentials in this work (deferred). secrets.yml is deprecated in Rails 7.2 and removed in Rails 8 — but `Rails.application.secrets` accessor is what's removed, not the file. Since Figaro is the actual secret store, this is moot for us; we just need to confirm no live code reads `Rails.application.secrets.X`. `grep -rn "Rails.application.secrets"` step is in the 7.2 → 8.0 PR.
- **`sass-rails ~> 5.0`** (`Gemfile:9`) and **Sprockets 3.7.5** (transitive) — both work through Rails 8 if pinned correctly. Sprockets 4 is required by Rails 7+; the bump comes for free via `bundle update`. `sass-rails 5.x` works against Sprockets 4 with a small compatibility shim — if it breaks, swap to `sassc-rails ~> 2.1` (drop-in).
- **`uglifier`** (`Gemfile:11`) and **`coffee-rails`** (`Gemfile:13`) — both still functional through Rails 8. Don't remove in this work; they're in `app/assets/javascripts/`. Removing them is a separate cleanup ticket.
- **`turbolinks` 5.2.1** (`Gemfile:20`) is compatible with Rails 8 with the `turbolinks` gem still installed. The `vue-turbolinks` adapter on the onboarding pack continues to work. Replacing turbolinks with Turbo is in `future_considerations.md`.
- **Capistrano deploy** (`config/deploy.rb`) uses `capistrano3-delayed-job` (`Gemfile:122`) for worker management. There is no first-party "capistrano3-solid-queue." We replace it with a small custom Capistrano task that restarts a systemd unit (or directly runs `bin/jobs`), defined in `lib/capistrano/tasks/solid_queue.rake`. Spec'd in step 7.
- **Bundler is at 2.5.9** (`Gemfile.lock`). Compatible with all target Rails versions. No Bundler bump needed.
- **CI:** No `.github/workflows/`, `.circleci/`, or `.travis.yml` was located during exploration. If CI is set up elsewhere (Buildkite, Semaphore, etc.) the per-step verification still applies; pull the config in and add it to the plan if discovered before step 0.

---

## Step-by-Step Plan

Each numbered step below is one PR, one branch, one deploy. Don't combine.

### Step 0 — Pre-flight hygiene (still on Rails 6.0)

**Goal:** Get the codebase into a known-clean state so each upgrade PR's diff is purely the upgrade.

1. Branch `chore/rails-upgrade-prep` off master.
2. Run `bundle outdated` and snapshot output. Bump *patch versions only* of non-Rails gems where safe (sentry-ruby, devise, pundit, factory_bot_rails, rspec-rails, etc.). Goal is to get to gem versions that are documented to support both Rails 6 and Rails 7+, so subsequent steps don't conflate "Rails moved" with "this gem moved."
3. Run `bundle exec rspec` — must be green. If specs are flaky/skipped, add an explicit list of skipped specs to this PR description so future steps don't accidentally re-skip.
4. Run `bin/rails zeitwerk:check`. Fix any classpath issues — these block 6.1+.
5. Add `config.load_defaults 6.0` explicitly to `config/application.rb` (after `class Application < Rails::Application`, before the existing autoload_paths). This is the one config change in this PR.
6. Smoke-test in production for ≥48 hours. Confirm Sentry hasn't lit up.

**Verification:** `bundle exec rspec`, manual smoke (login, list estimates, view a quote, send a quote email, edit a customer), Sentry quiet for 48h.

**Files touched:** `Gemfile`, `Gemfile.lock`, `config/application.rb`.

---

### Step 1 — Rails 6.0 → 6.1

**Goal:** Move to 6.1 on its own defaults.

1. `Gemfile:5` → `gem 'rails', '~> 6.1.7'`. Pin patch precisely on the lock.
2. `bundle update rails`. Address bundler conflicts; `webpacker` 5.x is fine here, no change needed.
3. Run `bin/rails app:update`. Hand-merge each diff:
   - `config/application.rb` — accept new boilerplate but preserve the custom autoload_paths and `active_job.queue_adapter = :delayed_job` line.
   - `config/environments/{development,production,test}.rb` — review every diff. Notable Rails 6.1 changes: `ActiveRecord::Base.has_many_inversing` defaults to true, `ActiveSupport::Cache::Store.preload_assets` config, `config.active_job.retry_jitter`.
   - `config/initializers/new_framework_defaults_6_1.rb` — accept the file generated by `app:update` *with all values commented out*. We turn them on with `config.load_defaults 6.1` in the follow-up PR, not here.
4. Run `bin/rails zeitwerk:check`. Fix.
5. Run `bundle exec rspec`. Address failures one at a time. Common 6.1 breakages:
   - `ActiveRecord::Base#changed?` semantics inside `before_save` callbacks.
   - `where.not(field: [nil, ''])` SQL emission changes.
   - `Rails.application.config.action_dispatch.return_only_request_media_type_on_content_type` (we want the new behavior).
6. Manual smoke. Sentry quiet 48h.
7. **Follow-up PR (not part of this step's scope but blocking step 2):** flip `config.load_defaults 6.1` in `config/application.rb`, soak again.

**Verification:** rspec green, manual smoke (estimate flow end-to-end, mailer flow, S3 upload, PDF generation via wicked_pdf, Excel export via caxlsx), Sentry quiet 48h. Then a separate PR bumps `config.load_defaults` and re-soaks.

**Files touched:** `Gemfile`, `Gemfile.lock`, `config/application.rb`, `config/environments/*.rb`, `config/initializers/new_framework_defaults_6_1.rb` (new).

---

### Step 2 — Webpacker → Shakapacker (still on Rails 6.1)

**Goal:** Replace `webpacker` with `shakapacker` so Rails 7 is reachable. No Vue or pack content changes.

1. `Gemfile`: replace `gem 'webpacker'` (line 64) with `gem 'shakapacker', '~> 7.3'`.
2. `package.json`: replace `"@rails/webpacker": "4.3.0"` with `"shakapacker": "^7.3"`. Update `webpack-dev-server` to `^4` (Shakapacker 7 expects webpack-dev-server 4). Run `yarn install`.
3. Rename `config/webpacker.yml` → `config/shakapacker.yml`. Diff against Shakapacker's default config and adopt new keys: `nested_entries`, `css_extract_ignore_order_warnings`, `webpack_loader: 'babel'`. Keep `source_path: app/javascript`, `source_entry_path: packs`, `public_output_path: packs`.
4. `config/webpack/environment.js`: change the import from `@rails/webpacker` to `shakapacker`. The VueLoaderPlugin block and the `config/webpack/alias.js` (`@ → app/javascript`) and `config/webpack/loaders/vue.js` (vue-loader rule) remain unchanged.
5. `config/webpack/{development,production,test}.js`: change require from `@rails/webpacker` to `shakapacker`.
6. `bin/webpack` and `bin/webpack-dev-server`: regenerate via `bin/rails shakapacker:binstubs` (or hand-edit the require path).
7. `config/initializers/assets.rb`: no changes needed — Sprockets is unaffected.
8. Frontend pack helpers (`javascript_pack_tag`, `stylesheet_pack_tag`) remain identical — Shakapacker preserves the API. The custom `javascript_bundle_tag` helper used in `app/views/layouts/{admin_vue,onboarding_page,property_management}.html.erb` is project code, not a Webpacker helper, so it's unaffected. Verify it still resolves. `grep -rn "javascript_bundle_tag\|stylesheet_pack_tag\|javascript_pack_tag" app/views/`.
9. CI/dev: `./bin/webpack` (one-shot build) and `./bin/webpack-dev-server` (HMR) must both produce a working bundle.
10. Smoke-test all three packs in development:
    - Admin SPA: load `/admin`, navigate the Vue Router pages (estimates, customers, hours, schedule, receipts), confirm Vuex store hydrates and BootstrapVue components render.
    - Onboarding: load the public onboarding URL with turbolinks active, confirm `vue-turbolinks` adapter still hooks navigation.
    - Property Management: load `/property-management`, confirm form components mount.
11. Production smoke after deploy: same three packs, same routes, plus image upload (which lives under the admin SPA and depends on `axios`/the upload service). The `aws-sdk-s3` Rails side is unaffected.

**Verification:** all three packs build, all three packs render in dev and production, image upload works end-to-end (S3 presigned URL flow), no console errors, `webpack-dev-server` HMR works in development. Sentry quiet 48h.

**Files touched:** `Gemfile`, `Gemfile.lock`, `package.json`, `yarn.lock`, `config/shakapacker.yml` (renamed from `config/webpacker.yml`), `config/webpack/{environment,development,production,test}.js`, `bin/webpack`, `bin/webpack-dev-server`.

---

### Step 3 — Rails 6.1 → 7.0

**Goal:** Move to 7.0. This is the biggest minor in terms of framework defaults (form helper changes, ActiveSupport::Encrypted serializer, new `config.action_view.button_to_generates_button_tag`).

1. Same shape as Step 1: bump `gem 'rails', '~> 7.0.8'`, `bundle update rails`, run `bin/rails app:update`, hand-merge.
2. Common 7.0 breakages to expect:
   - `ActiveRecord::Base.connection.execute` SQL injection helpers — `find_by_sql` semantics tightened.
   - `ActionView::Helpers::FormHelper#button_to` now generates `<button>`, not `<input>`. Search `app/views/` for visual regressions.
   - `config.action_dispatch.cookies_serializer = :json` — already set in `config/initializers/cookies_serializer.rb`, no change.
   - `ActiveSupport::Cache::MemCacheStore` requires explicit pool config. We don't use memcache. Skip.
   - **Devise compatibility:** Devise 4.9.x supports Rails 7.0. Confirm on `bundle update rails`.
3. `active_model_serializers 0.10.15` — first risk point. If specs break, pin to a community fork (e.g. `gem 'active_model_serializers', github: 'rails-api/active_model_serializers', branch: '0-10-stable'`) rather than rewrite serializers.
4. `wicked_pdf 2.1.0` — confirm PDF generation still works. Check on the quote PDF flow.
5. `caxlsx 4.2.0` and `caxlsx_rails 0.6.4` — confirm Excel exports still work.
6. `twitter-bootstrap-rails 5.0.0` — high risk of breaking. If it does, REMOVE the gem and replace its generators with static partials. Don't get stuck here.
7. `bundle exec rspec` green.
8. Manual smoke. Sentry quiet 48h.
9. **Follow-up PR:** flip `config.load_defaults 7.0`, soak.

**Verification:** rspec green, manual smoke covering quote PDF, invoice PDF, Excel export, mailer flows, S3 upload, Devise password reset.

**Files touched:** `Gemfile`, `Gemfile.lock`, `config/application.rb`, `config/environments/*.rb`, `config/initializers/new_framework_defaults_7_0.rb` (new).

---

### Step 4 — Rails 7.0 → 7.1

**Goal:** Move to 7.1. Smaller diff than 7.0.

1. `gem 'rails', '~> 7.1.5'`, `bundle update rails`, `bin/rails app:update`, hand-merge.
2. Expected breakages:
   - **`ActiveRecord::Base.default_connection_handler`** changes — most apps unaffected; we have a single MySQL config, so no impact.
   - **`config.action_dispatch.default_headers`** — a new `Strict-Transport-Security` default. Verify HTTPS is fully enforced in production (it is — Capistrano + nginx + Passenger setup).
   - **`ActiveSupport::MessageVerifier` rotations** — only matters if we rotate keys, which we don't.
3. `bundle exec rspec` green.
4. Manual smoke. Sentry quiet 48h.
5. **Follow-up PR:** flip `config.load_defaults 7.1`, soak.

**Files touched:** Same shape as previous Rails minor bumps.

---

### Step 5 — Rails 7.1 → 7.2

**Goal:** Move to 7.2. This is the LTS-ish stop and the smallest minor.

1. `gem 'rails', '~> 7.2.2'`, `bundle update rails`, `bin/rails app:update`, hand-merge.
2. Expected breakages:
   - **`Rails.application.secrets` removed.** We need `grep -rn "Rails.application.secrets" .` to confirm zero usages. If any exist, replace with `Rails.application.credentials.X` *or* `Figaro.env.X` (latter preferred — we're not switching to credentials in this work).
   - `config/secrets.yml` becomes inert (file can stay, just not read). Leave it; deletion is in step 8.
   - **`ActionDispatch::Request#raw_post`** subtle behavior change for empty bodies — only affects custom middleware. We have none.
3. `bundle exec rspec` green.
4. Manual smoke. Sentry quiet 48h.
5. **Follow-up PR:** flip `config.load_defaults 7.2`, soak.

**Files touched:** Same shape.

---

### Step 6 — Rails 7.2 → 8.0

**Goal:** Move to 8.0. We do *not* install Solid Queue in this PR — that's step 7. We just want the framework upgrade to be reviewable on its own.

1. `gem 'rails', '~> 8.0.1'`, `bundle update rails`, `bin/rails app:update`, hand-merge.
2. Expected breakages:
   - **Ruby 3.2 minimum.** We're on 3.3.1. ✓
   - **`ActiveSupport::Deprecation` API** — `ActiveSupport::Deprecation.deprecate_methods` etc. moved. Unlikely to affect app code; possible in some gems.
   - **Sprockets-rails 3.5+ required.** `bundle update sprockets-rails` covers it.
   - **`config.active_record.run_after_transaction_callbacks_in_order_defined`** new default — verify any AR callback ordering assumptions in models with multiple `after_commit` hooks.
   - **`config.active_record.before_committed_on_all_records`** new default — affects `before_destroy` + `dependent: :destroy` chains. Audit `Estimate` and `Organization` models specifically (they have the deepest associations).
3. `delayed_job_active_record 4.1.x` — confirm it loads on Rails 8 (it does in current versions, but the warning may be loud). This is the last PR where delayed_job runs; it's deliberately kept here to isolate "Rails 8 itself" from "Solid Queue swap."
4. `bundle exec rspec` green.
5. Manual smoke. Sentry quiet 48h.
6. **Follow-up PR:** flip `config.load_defaults 8.0`, soak.

**Files touched:** Same shape, plus `config/initializers/new_framework_defaults_8_0.rb` (new).

---

### Step 7 — Solid Queue swap

**Goal:** Retire delayed_job. Solid Queue takes over as the ActiveJob backend.

1. **Add the gem.** `Gemfile`: add `gem 'solid_queue', '~> 1.0'`. Optionally `gem 'mission_control-jobs'` for a web UI (admin-only routes); recommended but not required.
2. **Run the installer.** `bin/rails generate solid_queue:install`. This creates:
   - `db/migrate/<ts>_create_solid_queue_tables.rb` — adds ~9 tables (`solid_queue_jobs`, `solid_queue_ready_executions`, `solid_queue_scheduled_executions`, `solid_queue_recurring_executions`, `solid_queue_blocked_executions`, `solid_queue_failed_executions`, `solid_queue_pauses`, `solid_queue_processes`, `solid_queue_semaphores`).
   - `config/queue.yml` — worker/dispatcher configuration.
   - `config/recurring.yml` — empty by default; we don't use recurring jobs yet.
3. **Run the migration.** `bin/rails db:migrate`. Tables land in the main `bigtrees_dev`/`bigtrees_production` database (per locked decision: single DB, no separate `queue` connection).
4. **Switch the adapter.** `config/application.rb:32`:
   ```ruby
   # was: config.active_job.queue_adapter = :delayed_job
   config.active_job.queue_adapter = :solid_queue
   ```
5. **Worker process.** Replace `bin/delayed_job` with `bin/jobs` (Solid Queue ships its own binstub via the installer). Old binstub stays in the tree for one deploy in case rollback is needed; remove in step 8.
6. **Cron / whenever.** `config/schedule.rb:25-27`:
   - **Before:** `command "cd /var/www/bigtrees/current && RAILS_ENV=production bin/delayed_job -n 2 restart"`
   - **After:** the cron-based restart was a workaround for delayed_job memory growth. Solid Queue is engineered to run as a long-lived process; we should run it as a systemd unit, not restart it every 3 hours. **Remove the cron entry from `schedule.rb` entirely** and add a systemd unit (or update Capistrano to manage the process — see next item).
7. **Capistrano.**
   - Remove `gem 'capistrano3-delayed-job'` from the Gemfile development group.
   - Remove `set :delayed_job_server_role, :worker` and `set :delayed_job_workers, 1` from `config/deploy.rb:30-31`.
   - Add `lib/capistrano/tasks/solid_queue.rake` with two tasks: `solid_queue:start`, `solid_queue:restart`. Implementation runs `sudo systemctl restart bigtrees-solid-queue` (or, if systemd isn't available on the box, `bundle exec bin/jobs` daemonized via `nohup` — last-resort).
   - In `config/deploy.rb`, add `after 'deploy:publishing', 'solid_queue:restart'`.
   - On the production server: create `/etc/systemd/system/bigtrees-solid-queue.service` (one-time manual setup, document in PR description). Unit runs `cd /var/www/bigtrees/current && bundle exec bin/jobs`.
8. **Mailers stay synchronous.** Per locked decision, no `.deliver_now → .deliver_later` migration in this PR. The 12 callsites identified earlier (`jobs_controller.rb:20`, `jobs_controller.rb:51`, `commercial_requests_controller.rb:7`, `customer_requests_controller.rb:47`, `equipment_requests_controller.rb:33`, `receipts_controller.rb:38`, `arborists_controller.rb:40`, `arborists_controller.rb:54`, plus the four `QuoteMailer.new.quote_email` direct-call sites) are unchanged.
9. **Drain delayed_job before deploy.** Pre-deploy: `RAILS_ENV=production bin/delayed_job stop`, then `Delayed::Job.count` must be 0 before proceeding. Given current usage, it will be.
10. **Do NOT drop `delayed_jobs` table or remove `delayed_job_active_record`/`delayed_job` gems in this PR.** Keeping them in lets us roll back the adapter line in `application.rb` as a one-line emergency revert. They come out in step 8.

**Verification:**
- `bundle exec rspec` green.
- Local: enqueue a one-shot test job (`ApplicationJob.set(wait: 1.second).perform_later` in a console) and confirm Solid Queue picks it up (`solid_queue_jobs` table populated, then drained).
- Confirm `bin/jobs` boots cleanly against the production-shape config.
- Production: deploy, verify systemd unit is `active (running)`, watch `solid_queue_processes` table for heartbeat. Idle for ≥1 hour confirms no exception loop.
- Sentry quiet 48h.

**Files touched:** `Gemfile`, `Gemfile.lock`, `config/application.rb`, `config/queue.yml` (new), `config/recurring.yml` (new), `config/schedule.rb` (cron entry removed), `config/deploy.rb` (delayed_job lines removed, solid_queue task wired), `lib/capistrano/tasks/solid_queue.rake` (new), `db/migrate/<ts>_create_solid_queue_tables.rb` (new), `bin/jobs` (new, generated). Plus production server: `/etc/systemd/system/bigtrees-solid-queue.service` (manual one-time setup).

---

### Step 8 — Cleanup

**Goal:** Remove the dead delayed_job code path. Only after step 7 has been stable in production for ≥7 days.

1. Remove `gem 'delayed_job_active_record'` and `gem 'daemons'` from `Gemfile` (lines 36-37). `bundle install`.
2. Drop the `delayed_jobs` table: new migration `db/migrate/<ts>_drop_delayed_jobs_table.rb`.
3. Remove `bin/delayed_job`.
4. Confirm no references to `Delayed::` remain: `grep -rn "Delayed::\|delayed_job" app/ lib/ config/ db/`. The migration that *created* `delayed_jobs` (`db/migrate/20180424191655_create_delayed_jobs.rb`) stays — it's history.
5. (Optional, can be a follow-up) Delete `config/secrets.yml` since `Rails.application.secrets` no longer exists in 8.0 and Figaro is the actual secret store.

**Verification:** `bundle exec rspec` green, `bundle install` clean, application boots, Solid Queue continues operating normally in production for 24h post-cleanup.

**Files touched:** `Gemfile`, `Gemfile.lock`, `bin/delayed_job` (deleted), `db/migrate/<ts>_drop_delayed_jobs_table.rb` (new). Optionally `config/secrets.yml` (deleted).

---

## Cross-Cutting Verification

These checks are run on **every** numbered PR, regardless of step:

- `bundle exec rspec` — full suite green.
- `bin/rails zeitwerk:check` — autoloader clean.
- `bundle exec rails s` boots in development without warnings.
- Manual smoke list (~15 minutes):
  1. Login as an admin (Devise password reset works).
  2. Create an estimate, transition through statuses (`needs_costs` → `pending_quote`).
  3. Send a quote email (Nylas / SMTP path works).
  4. Generate a quote PDF (wicked_pdf works).
  5. Export an Excel report (caxlsx works).
  6. Upload a tree image (S3 presigned PUT works).
  7. Enqueue a job (delayed_job in steps 0–6, Solid Queue in step 7+) and confirm it runs.
  8. View Sentry — no new exception classes since pre-deploy.
- Production soak: ≥48 hours quiet on Sentry before the next step's PR opens.

---

## Risks & Tradeoffs

1. **`twitter-bootstrap-rails` 5.0.0 is a ticking clock.** It hasn't been released since 2018. It will probably break before we finish the upgrade — most likely at Rails 7.0. The plan above flags it; if it breaks, **remove the gem** rather than try to patch it. Any view code that depends on its generators can be inlined in <1 hour.
2. **`active_model_serializers` 0.10.x is the second ticking clock.** It's community-maintained but lags. If a minor breaks it, pin to a community fork, do not rewrite serializers in this work.
3. **`config.load_defaults` is split across two PRs per minor — gem bump first, defaults bump second.** This doubles the PR count (5 minors × 2 = 10 PRs total just for Rails, plus Shakapacker, Solid Queue, cleanup = 13 PRs end-to-end). Tradeoff: each PR is cleanly revertable. Worth it.
4. **Per-step soak time accumulates.** With 48h soaks per PR plus weekend gaps, end-to-end calendar time is realistically **6-10 weeks**, not the engineering time. If we want to compress this, soaks can be shorter (24h) but every step needs Sentry-backed confidence first.
5. **Solid Queue is single-process by default.** Replacing 2 delayed_job workers with 1 Solid Queue process is a load-shape change. Given current job volume is ~zero, this is a non-issue — but if the org starts doing async mail in earnest, increase workers via `config/queue.yml`.
6. **Production systemd unit setup is a one-time manual step.** It's outside Capistrano; documented in step 7's PR description. Easy to forget on a new deploy server. Long-term, a Kamal migration (deferred) makes this go away.
7. **Rolling back step 7 means rolling back to delayed_job.** That's why step 8 (drop the table, remove the gems) is a separate PR with a 7-day delay. If Solid Queue misbehaves, the revert is a one-line change to `config/application.rb` plus restarting delayed_job from the still-present binstub.
8. **CI may not exist.** Exploration didn't find a CI config. If there is none, the verification steps are entirely manual on a developer's machine. This is a much bigger risk than the upgrade itself — a broken Rails minor is way easier to ship through if no automated suite runs. Strongly consider standing up basic GitHub Actions running `bundle exec rspec` *before* starting step 0.
9. **`mini_racer` (`Gemfile:44`) requires re-compilation against new Ruby/Rails.** Rare to break, but `bundle install` may need `--force-ruby-platform` on Apple Silicon. Document in the README if it bites.
10. **Webpacker → Shakapacker swap may require Vue 2.7 (or staying on 2.6.x).** Vue 2.6.12 is currently pinned (`package.json:10`). Shakapacker 7 + vue-loader 15 + Vue 2.6 is the documented working combo; if vue-loader needs a bump, do it as part of step 2 — not a separate PR.

---

## Critical Files

**Must touch (every step):**
- `Gemfile`, `Gemfile.lock`
- `config/application.rb`
- `config/environments/{development,production,test}.rb`

**Step-specific:**
- Step 1: `config/initializers/new_framework_defaults_6_1.rb` (new)
- Step 2: `package.json`, `yarn.lock`, `config/shakapacker.yml` (renamed), `config/webpack/{environment,development,production,test}.js`, `bin/webpack`, `bin/webpack-dev-server`
- Step 3: `config/initializers/new_framework_defaults_7_0.rb` (new)
- Step 4: `config/initializers/new_framework_defaults_7_1.rb` (new)
- Step 5: `config/initializers/new_framework_defaults_7_2.rb` (new)
- Step 6: `config/initializers/new_framework_defaults_8_0.rb` (new)
- Step 7: `config/queue.yml` (new), `config/recurring.yml` (new), `config/schedule.rb`, `config/deploy.rb`, `lib/capistrano/tasks/solid_queue.rake` (new), `db/migrate/<ts>_create_solid_queue_tables.rb` (new), `bin/jobs` (new, generated). Plus systemd unit on production server.
- Step 8: `bin/delayed_job` (deleted), `db/migrate/<ts>_drop_delayed_jobs_table.rb` (new). Optionally `config/secrets.yml` (deleted).

**Must verify on every step (no edits expected):**
- `app/javascript/packs/{admin,onboarding,property_management}.js`
- `app/views/layouts/{application,admin_vue,white_label,onboarding_page,property_management}.html.erb`
- `db/schema.rb`
- `bin/rails`, `bin/rake`

---

## Out of Scope (explicitly)

- Vue 2 → Vue 3 migration.
- Rails encrypted credentials migration.
- Sprockets → Propshaft.
- Turbolinks → Turbo (Hotwire).
- Dockerfile / Kamal deployment.
- Converting any `.deliver_now` mailer to `.deliver_later`.
- Standing up a separate `queue` database for Solid Queue.
- Removing `coffee-rails`, `uglifier`, `jquery-rails`, `twitter-bootstrap-rails` (other than as forced by upgrade breakage).
- Adding CI if it doesn't exist (recommend doing this first, but it's a separate ticket).

These are all listed in `future_considerations.md` (or noted above) so the ticket boundary is unambiguous.
