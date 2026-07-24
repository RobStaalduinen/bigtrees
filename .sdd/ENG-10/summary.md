# ENG-10 — Durable, Optimistic Background Image Uploads · Summary

**Status:** All 9 chunks implemented & unit/contract-tested. **Not yet merged.** Manual
acceptance test + code review still outstanding (see bottom).
**Branch:** `image-update`
**Plan:** `.sdd/ENG-10/implementation_plan.md` (every chunk heading marked ✅)

---

## What this feature does

Field arborists upload tree photos on weak connections. ENG-4 made the **S3 transfer**
resilient; the remaining pain ("stuck at 100%") was the **DB association** step, which was
coupled to the Save button and not fault-tolerant.

ENG-10 makes association as durable as the transfer:
- A **global `UploadManager` singleton** owns all upload jobs, backed by **IndexedDB**, so
  jobs survive route navigation **and** page reload (resume-on-foreground; *not* closed-app).
- Each job runs **two decoupled tracks**: (a) get the file into S3, (b) ensure a `TreeImage`
  DB row exists. The row is created **placeholder-first** (null `image_url`) the moment its
  target is known, then the URL is filled once S3 finishes. The job is `done` only when both
  hold.
- Association uses a new **idempotent** endpoint keyed on a client-generated `client_upload_id`
  (`find_or_create_by`), so retries/multi-tab/reload never create duplicate rows.
- Retryable failures retry **indefinitely** (capped, jittered backoff, online-aware); only
  fatal (auth/validation/4xx) stops.
- **Save no longer blocks** on uploads. A pending image is visible to *any* viewer of the
  estimate (placeholder row), and fills in on their next fetch (no realtime needed).

---

## Where the code lives

### Backend (Rails)
- `db/migrate/20260609000000_add_client_upload_id_to_tree_images.rb` — `client_upload_id:string`
  + unique index (nullable; multiple NULLs OK for legacy rows).
- `app/controllers/tree_images_controller.rb`
  - **`#associate`** (new) — idempotent on `client_upload_id`; sets `estimate_id`/`tree`; fills
    `image_url` only when present (never overwrites a URL with nil). `authorize Estimate, :update?`.
  - **`#show`** — `head :no_content` when `image_url` blank (pending placeholder).
- `app/controllers/trees_controller.rb` — **`#bulk_create`** no longer embeds images; returns
  `{ status: :ok, tree_ids: [...] }` in input order.
- `app/serializers/tree_image_serializer.rb` — derived **`ready`** attribute (`image_url.present?`).
- `app/models/tree_image.rb` — `imgix_url` guards `url.blank?`.
- `app/views/quotes/pdf/_images.html.erb` — filters to ready images (pending never in a quote PDF).
- `config/routes.rb` — `POST /tree_images/associate`.

### Frontend engine (`app/javascript/services/`)
- `upload/persistence.js` — async adapter (`all/get/put/patch/delete/purgeOlderThan`); IndexedDB
  with transparent **in-memory fallback** (private mode / unavailable).
- `UploadJob.js` — extended: `clientUploadId`, write-through persistence (debounced progress),
  indefinite capped backoff, online-aware resume, expired-multipart restart, and the **two-track
  association** (`s3Url` + `placeholderId` → `done`). Exports `NON_TERMINAL`/`TERMINAL`.
  - Statuses: `idle → compressing → preparing → uploading → finalizing`, then orthogonally
    `pendingAssociation` / `awaitingTarget`; terminal `done` (associating) or `success` (generic,
    no target). Targetless jobs behave exactly as before.
- `upload/uploadManager.js` — singleton: `enqueue/get/allJobs/jobsForTarget/resolveTarget/retry/
  remove/subscribe/summary/hydrate/clear/init`. Hydrates + resumes on boot, Web Locks driver
  guard, global online/offline listeners, TTL(7d)+`done` purge on hydrate & hourly.

### Frontend components
- `components/file/uploader.vue` — **`<app-uploader>`** (global). Manager-backed, optimistic
  `URL.createObjectURL` previews, per-item retry/remove, emits `input` `[{id,clientUploadId,
  status,url}]` + `summary`. Owns no upload state → survives unmount/remount via v-model.
- `components/file/uploadIndicator.vue` — **`<app-upload-indicator>`** nav-bar badge (active/
  failed counts + list w/ retry/remove).
- `components/tree_images/actions/addNew.vue` — **existing-quote** flow: `<app-uploader>` with a
  resolved target; non-blocking Save; debounced `ESTIMATE_UPDATED` refetch.
- `components/createEstimate/taskForm.vue` + `estimateForm.vue` — **new-quote** flow: per-task
  `<app-uploader :target="{pending:true}">`; submit → `bulk_create` (no images) → read `tree_ids`
  → `manager.resolveTarget(jobId, {estimate_id, tree_id})` per task (length-asserted) → navigate.
- `components/tree_images/forms/imageThumb.vue`, `views/galleryModal.vue`, `views/markup.vue` —
  null-`image_url` safety (pending placeholder; edit disabled for pending).
- `packs/admin.js` — `initUploadManager()` at boot + `Vue.prototype.$uploads`; registers
  `app-uploader`. `nav.vue` — renders indicator; logout calls `$uploads.clear()`.

### Test infra / conventions introduced
- **ESM boundaries** for `node --test`: `services/package.json` and `services/upload/package.json`
  both `{"type":"module"}`. One extensionless import fixed (`uploadClient` → `./uploadTelemetry.js`).
- `package.json` script: **`yarn test:js`** = `node --test app/javascript`.
- Browser-coupled deps in `UploadJob` (`awsS3Utils`, `browser-image-compression`) are **lazy
  dynamic imports + injectable** so the job unit-tests under plain Node.

---

## How to verify

```bash
yarn test:js                 # 37 pass — persistence, UploadJob, association, manager
bundle exec rspec \
  spec/controllers/tree_images_controller_spec.rb \
  spec/controllers/trees_controller_spec.rb \
  spec/models/tree_image_spec.rb \
  spec/views/quotes/pdf/_images.html.erb_spec.rb   # 11 pass
NODE_ENV=development ./bin/shakapacker               # builds clean
```

---

## Outstanding before merge

1. **Manual acceptance test (the plan's gate, NOT yet done):** throttled-network new-quote
   submit-then-background-finish with **pending images visible to a second viewer**; existing-quote
   non-blocking Save; mid-upload **reload resumes and fills URLs**; no duplicate rows; no null
   exceptions on an estimate/gallery/quote-PDF with a pending image; logout clears IndexedDB.
2. **Code review.**
3. **No automated `.vue` render tests** — repo lacks a jsdom/`@vue/test-utils` harness; component
   correctness rests on build + the unit-tested manager/job layers.
4. **`fake-indexeddb` not added** — real IDB read/write path covered structurally + via in-memory
   adapter + fallback tests, not executed in Node.
5. **Legacy kept (planned follow-ups):** `create_from_urls` (no longer called by `addNew`),
   `uploadList.vue`/`multiUpload.vue`; new-quote per-task slot *appends* rather than single-replace
   (both jobs resolve to the same tree — correct, just a UX nuance).
6. **Out of scope (from plan):** migrating other upload entry points (receipts/notes/generic
   files); server-side S3 lifecycle sweep of orphaned objects; persisting full new-quote form draft.

## Key design decisions (so you don't re-litigate)
- Association is a **separate** idempotent endpoint (`/tree_images/associate`); presign endpoints
  unchanged. `create_from_urls` stays until all callers migrate.
- `client_upload_id` is a UUID → plain global unique index; `find_or_create_by` is the upsert.
- IndexedDB buys **resume-on-foreground + retry-forever**, NOT closed-app upload (iOS can't).
- Abandoned new-quote jobs create **no** placeholder (target never resolves) → only an orphaned
  S3 object (accepted); client job TTL-purged after 7 days.
