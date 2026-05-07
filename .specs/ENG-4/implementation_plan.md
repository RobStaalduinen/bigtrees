# Implementation Plan: Image Upload Resilience for Poor Cell Service

**Spec:** ENG-4
**Date:** 2026-05-06

---

## Overview

Field arborists upload tree photos and receipts on weak cell connections. Today the upload progress halts mid-stream or sticks at 100% forever, with no error feedback and no way to retry — the user is left staring at a stuck spinner.

Root causes confirmed in `app/javascript/mixins/axiosMixin.js:59-71`:

- `axiosImagePost` has **no `.catch()`**, **no timeout**, **no retry**. A hung S3 request hangs forever; `uploading` state never resets.
- Presigned POST URLs expire after 15 minutes with no refresh path.
- XML response parsing in `utils/awsS3Utils.js` silently returns `undefined` on parse failure.
- Each upload is a single monolithic POST — any network drop loses the whole file.

**Approved scope:** tactical resilience (errors, timeouts, retries, URL refresh) + S3 multipart chunked uploads, applied to all upload entry points (tree images, receipts, generic files), with inline Retry/Remove buttons on each thumbnail.

---

## Approach

Centralize upload logic into one shared service layer so the existing entry points (`singleUploader.vue`, `upload.vue`, `imageUpload.vue`, `tree_images/forms/uploader.vue`, `multiUpload.vue`) all delegate to a single resilient implementation. Single-shot remains the path for files ≤ 5 MiB after compression (the common case — `browser-image-compression` targets 1 MB); multipart kicks in only for larger files.

Per-file state lives in a plain-JS `UploadJob` class (not Vuex — no shared cross-app state). Each Vue thumbnail subscribes to its own job. Multipart resumes only the failed parts; single-shot retries the whole blob.

---

## Discovery Notes & Pre-flight Decisions

These were confirmed during exploration and shape the implementation:

- **Sentry on the frontend is NOT wired.** `Gemfile` has `sentry-ruby` and `sentry-rails`; `package.json` has no `@sentry/browser` or `@sentry/vue`. CLAUDE.md mentions Sentry but it's Rails-only today. **Decision:** ship a no-op telemetry shim (`uploadTelemetry.js`) with `breadcrumb()`/`captureException()` that logs to console; swap for `@sentry/vue` in a follow-up PR.
- **Axios is `^0.20.0`** (`package.json:5`). Modern `AbortController`/`AbortSignal` requires `>= 0.22`. **Decision:** bump to `axios@^1.7` in this PR. All callers in the codebase use only `get/post/put/delete` (no `CancelToken`), so bump is low-risk. Smoke-test admin pages after bump.
- **Compressed file size guard.** `compressFile()` targets `maxSizeMB: 1`, but `browser-image-compression` is best-effort. Use a runtime check on the **resulting blob**: `if (blob.size <= 5 * 1024 * 1024) singleShot() else multipart()`. 5 MiB is S3's minimum non-final part size.
- **Single-shot uses presigned POST; multipart requires presigned PUT per part.** Different S3 API verbs, different signing. Keep single-shot on POST/XML untouched (just add try/catch around `parseString`); multipart introduces a parallel presigned-PUT path.
- **`axiosImagePost` deliberately omits `setupAxios()`** so CSRF/JSON headers don't pollute the S3 request. New `uploadClient` must preserve this — bare `axios.request(...)`, no `withCredentials: true` (would force CORS preflight failure).
- **No Jest config in the repo.** New services are framework-free plain JS — runnable under `node --test`. Adding Jest is a separate decision.

---

## File-by-File Plan

### New (frontend)

#### 1. `app/javascript/services/uploadClient.js` — resilient HTTP layer

```js
import axios from 'axios';
import { breadcrumb } from './uploadTelemetry';

const DEFAULT_TIMEOUT_MS = 60_000;
const MAX_ATTEMPTS = 3;
const BASE_BACKOFF_MS = 500;
const RETRYABLE_STATUSES = new Set([408, 425, 429, 500, 502, 503, 504]);

export class UploadCancelled extends Error {}
export class UploadFatal extends Error {}
export class UploadUrlExpired extends Error {}

function jitter(ms) {
  const delta = ms * 0.3;
  return ms - delta + Math.random() * 2 * delta;
}

function classify(error) {
  if (axios.isCancel(error)) return 'cancelled';
  if (error.code === 'ECONNABORTED') return 'retryable';
  if (!error.response) return 'retryable';
  const { status, data } = error.response;
  if (status === 403 && /Expired|SignatureDoesNotMatch|RequestTimeTooSkewed/i.test(String(data))) {
    return 'expired';
  }
  if (RETRYABLE_STATUSES.has(status)) return 'retryable';
  return 'fatal';
}

/**
 * putWithRetry — used for both single-shot PUT-style uploads and per-part PUTs.
 * @param {() => Promise<{url, headers?}>} resolveTarget
 *   Called every attempt that needs a fresh URL. For multipart, re-fetches the
 *   part URL from Rails. URL-expiry refresh does NOT consume retry budget.
 * @param {Blob} body
 * @param {(pct: number) => void} onProgress
 * @param {AbortSignal} signal
 * @param {number} timeoutMs
 */
export async function putWithRetry({ resolveTarget, body, onProgress, signal, timeoutMs = DEFAULT_TIMEOUT_MS }) {
  let target = await resolveTarget();
  let lastErr;
  for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
    if (signal.aborted) throw new UploadCancelled();
    breadcrumb('upload', 'attempt', { attempt, url: target.url });
    try {
      const res = await axios.request({
        method: 'PUT',
        url: target.url,
        data: body,
        headers: target.headers || {},
        timeout: timeoutMs,
        signal,
        onUploadProgress: e => {
          if (!e.total) return;
          onProgress(Math.round((e.loaded * 100) / e.total));
        },
      });
      return res;  // ETag in res.headers.etag for multipart
    } catch (err) {
      lastErr = err;
      const kind = classify(err);
      breadcrumb('upload', 'attempt-failed', { attempt, kind, status: err.response?.status });
      if (kind === 'cancelled') throw new UploadCancelled();
      if (kind === 'fatal') throw Object.assign(new UploadFatal(err.message), { cause: err });
      if (kind === 'expired') {
        target = await resolveTarget();
        attempt--;  // expired refresh does not burn budget
        continue;
      }
      if (attempt === MAX_ATTEMPTS) break;
      const delay = jitter(BASE_BACKOFF_MS * 2 ** (attempt - 1));
      await new Promise((res, rej) => {
        const t = setTimeout(res, delay);
        signal.addEventListener('abort', () => { clearTimeout(t); rej(new UploadCancelled()); }, { once: true });
      });
    }
  }
  throw Object.assign(new UploadFatal('exhausted retries'), { cause: lastErr });
}

// postWithRetry — same shape, presigned-POST verb + form-data body for single-shot.
```

#### 2. `app/javascript/services/UploadJob.js` — per-file state machine

Plain JS class, framework-free, unit-testable. Vue components subscribe via tiny event emitter (or `Vue.observable` if preferred — pick one).

```js
class UploadJob {
  constructor(file, options) {
    this.id = options.id ?? crypto.randomUUID();
    this.file = file;
    this.options = {
      compress: true,
      multipartThreshold: 5 * 1024 * 1024,
      partSize: 5 * 1024 * 1024,
      partConcurrency: 3,
      ...options,
    };
    this.status = 'idle';
    this.progress = 0;          // 0–100, weighted across parts
    this.error = null;          // { message, retryable }
    this.url = null;            // final S3 URL on success
    this.parts = [];            // [{partNumber, status, etag, blob, urlIssuedAt}]
    this.uploadId = null;       // S3 multipart upload id
    this.key = null;            // S3 object key
    this._abort = new AbortController();
    this._listeners = new Set();
  }

  on(fn)    { this._listeners.add(fn); return () => this._listeners.delete(fn); }
  _emit()   { for (const fn of this._listeners) fn(this); }

  start()   { /* compress → decide single vs multi → drive */ }
  retry()   { /* requires status === retryableError; resume from manifest */ }
  abort()   { /* signal + fire-and-forget DELETE on multipart */ }
}
```

**State machine:**

```
idle ──start()──▶ compressing ──▶ preparing ──▶ uploading ──▶ finalizing ──▶ success
                                                   │              │
                                                   ▼              ▼
                                          retryableError ──retry()──▶ uploading
                                            (Retry+Remove)
                                                   │
                                                   ▼ (3 attempts exhausted, or non-retryable)
                                              fatalError
                                              (Remove only)

abort() from any state ──▶ cancelled (fire-and-forget DELETE on multipart)
```

**Resume on retry (multipart):** the `parts` array is the resume manifest. Already-acknowledged parts (status `done`, ETag captured) are skipped. `uploadId` and `key` survive across retries. **Per-part presigned URLs expire in 15 min**, so the retry path re-fetches part URLs whenever a part attempt yields `expired`, or proactively whenever >12 min have passed since last issuance (`urlIssuedAt`). The S3 `uploadId` itself does NOT expire on a clock — only the part URLs.

**Resume on retry (single-shot):** there's no partial state to preserve; re-fetch presigned POST and re-upload the whole compressed blob.

**Concurrency:** cap parallel parts at 3. Higher hurts on cell connections. Implement as a worker pool over `parts`. Don't `Promise.all` over all parts — one slow part shouldn't block the next.

**Backoff:** 500ms → 1000ms → 2000ms with ±30% jitter; 60s timeout per part; `expired` refreshes URL without burning a retry attempt; non-retryable 4xx → `fatalError` immediately.

#### 3. `app/javascript/services/multipartChunker.js` — pure helper

```js
export function chunksFor(file, partSize) {
  const parts = [];
  let partNumber = 1;
  for (let start = 0; start < file.size; start += partSize) {
    const end = Math.min(start + partSize, file.size);
    parts.push({ partNumber, start, end, blob: file.slice(start, end) });
    partNumber++;
  }
  return parts;
}
```

#### 4. `app/javascript/services/uploadTelemetry.js` — telemetry shim

```js
export function breadcrumb(category, message, data) {
  if (process.env.NODE_ENV !== 'production') {
    console.debug(`[${category}] ${message}`, data);
  }
  // TODO: route to Sentry.addBreadcrumb when @sentry/vue is wired
}

export function captureException(err, ctx) {
  console.error('[upload-error]', err, ctx);
  // TODO: route to Sentry.captureException
}
```

#### 5. `app/javascript/components/file/uploadItem.vue` — canonical thumbnail

Owns one `UploadJob`. Subscribes via `mounted() { this._unsub = this.job.on(this.sync); } beforeDestroy() { this._unsub(); this.job.abort(); }`.

Template branches on `status`:

| Status | UI |
|---|---|
| `compressing` / `preparing` / `uploading` / `finalizing` | spinner + filename + (progress% if available) |
| `success` | thumbnail + filename + Remove (×) icon |
| `retryableError` | red 1px border, ⚠ icon, "Upload failed — check your connection", **Retry** (`b-icon arrow-clockwise`) + **Remove** (`b-icon x-circle`) |
| `fatalError` | red border, ⚠ icon, server message if safe else generic, **Remove only** |
| `cancelled` | not rendered (job removed from list) |

#### 6. `app/javascript/components/file/uploadList.vue` — replacement for multiUpload.vue

Renders `<b-form-file multiple>` and a list of `<uploadItem>`s. Emits a flat array via `v-model`:

```js
[
  { id: 'job-123', status: 'success', url: 'https://...', progress: 100 },
  { id: 'job-456', status: 'uploading', url: null, progress: 47 },
  { id: 'job-789', status: 'retryableError', url: null, errorMessage: 'Network error' },
]
```

Subscribes to `window.online`/`offline` events:
- `online` → call `job.retry()` on every job in `retryableError` (NOT `fatalError`)
- `offline` → call `job.pause()` on every in-flight job (aborts request, parks in `retryableError` with offline message — so we don't sit on a dead socket for 60s)

#### 7. `app/javascript/utils/uploadValidation.js` — shared submit guard

```js
export function uploadGuard(images) {
  if (!images.length) return { ok: false, message: 'Please add at least one image.' };
  const errored = images.filter(i => i.status === 'retryableError' || i.status === 'fatalError');
  if (errored.length) {
    return { ok: false, message: `${errored.length} image(s) failed to upload — retry or remove them before saving.` };
  }
  const inflight = images.filter(i => ['compressing','preparing','uploading','finalizing'].includes(i.status));
  if (inflight.length) {
    return { ok: false, message: 'Wait for image uploads to finish and try again.' };
  }
  return { ok: true };
}
```

Collapses duplicated logic in `tree_images/actions/addNew.vue:89-105` and `receipts/actions/create.vue:114-133`.

---

### Modified (frontend)

#### `app/javascript/mixins/axiosMixin.js`
Delete `axiosImagePost` (lines 59-71) and dead `axiosBase64ImagePost` (lines 90-95). Upload code now imports `uploadClient` directly. Keep `axiosGet/Post/Put/Delete/Download` and `setupAxios` unchanged.

#### `app/javascript/components/file/actions/singleUploader.vue`
Rewrite as thin wrapper around `<uploadItem>` for backward compat with existing slot expectations. Replace `uploadFile()` (lines 52-67) entirely. Remove direct calls to `axiosImagePost`, `signedUrlFormData`, `parseImageUploadResponse`.

#### `app/javascript/components/file/actions/upload.vue`
Replace `uploadFile()` (lines 73-86) with `new UploadJob(file).start()`. Keep `<b-form-file>` UI and `v-model` contract. **Preserve compression-failure fallback** (lines 137-150) — pass it through `UploadJob.options`.

#### `app/javascript/components/file/actions/imageUpload.vue`
Same; **preserve no-compression behavior** by passing `{ compress: false }` to `UploadJob`. Replace `uploadFile()` (lines 79-87).

#### `app/javascript/components/file/actions/multiUpload.vue`
Replace with re-export of `uploadList.vue`, OR update the ~8 `MultiImage`/`app-multi-image` import sites to use the new component name.

#### `app/javascript/components/tree_images/forms/uploader.vue`
Replace `beginUpload`/`uploadImage` (lines 34-61) with `UploadJob`. Add error UI in template (red border, retry icon, remove icon).

#### `app/javascript/components/tree_images/actions/addNew.vue`
Update `validate()` (lines 89-105) to call `uploadGuard()`. Loop now checks `image.status` instead of `image.uploading`.

#### `app/javascript/components/receipts/actions/create.vue`
Update `createReceipt()` (lines 114-155) to call `uploadGuard()`. Block on errored uploads with explicit message.

#### `app/javascript/utils/awsS3Utils.js`
Wrap `parseImageUploadResponse` in try/catch that throws a typed `XmlParseError`. Keep `signedUrlFormData` unchanged (still used for single-shot POST).

---

### New (backend)

#### `app/controllers/uploads/multipart_controller.rb`

```ruby
class Uploads::MultipartController < ApplicationController
  def create
    service = S3::MultipartUpload.new(
      bucket_name: params.require(:bucket_name),
      filename: params.require(:filename),
      content_type: params.require(:content_type),
    )
    result = service.initiate
    render json: { upload_id: result.upload_id, key: result.key }, status: :ok
  rescue Aws::S3::Errors::ServiceError => e
    Rails.logger.error("S3 multipart init failed: #{e.message}")
    render json: { error: 'Upload service unavailable' }, status: :bad_gateway
  end

  def parts
    service = S3::MultipartUpload.new(upload_id: params[:upload_id], key: params.require(:key))
    parts = service.presign_parts(params.require(:part_numbers).map(&:to_i))
    render json: { parts: parts }, status: :ok
  end

  def complete
    service = S3::MultipartUpload.new(upload_id: params[:upload_id], key: params.require(:key))
    url = service.complete(params.require(:parts))
    render json: { url: url }, status: :ok
  rescue Aws::S3::Errors::EntityTooSmall
    render json: { error: 'A part was below the 5MB minimum; please retry.' }, status: :unprocessable_entity
  end

  def destroy
    service = S3::MultipartUpload.new(upload_id: params[:upload_id], key: params.require(:key))
    service.abort
    head :no_content
  rescue Aws::S3::Errors::NoSuchUpload
    head :no_content  # idempotent
  end
end
```

Auth mirrors `FilesController#new` (same `ApplicationController` chain).

#### `app/services/s3/multipart_upload.rb`

Wraps `Aws::S3::Client` calls. Methods:

- `initiate` → `create_multipart_upload(bucket:, key:, content_type:, acl: 'public-read')`. Key follows existing pattern: `"#{bucket_name}/#{Rails.env}/#{SecureRandom.uuid}/#{filename}"`.
- `presign_parts(part_numbers)` → for each, build a presigned `upload_part` URL with 15-min expiry. Validate `part_numbers ∈ [1, 10000]`.
- `complete(parts)` → `complete_multipart_upload(multipart_upload: { parts: parts.sort_by { |p| p[:part_number] } })`. Validate part numbers form a contiguous sequence starting at 1. Return canonical URL: `"https://#{ENV['FOG_BUCKET']}.s3.amazonaws.com/#{key}"`.
- `abort` → `abort_multipart_upload(bucket:, key:, upload_id:)`. Idempotent — `NoSuchUpload` is treated as success.

Reuse credential setup from `FilesController#new` (lines 3-11) — extract into `S3::Client.build` if desired, but optional for this PR.

#### Backend specs

- `spec/controllers/uploads/multipart_controller_spec.rb` — auth, happy paths for create/parts/complete/destroy, AWS error wrapping (`Aws::S3::Errors::ServiceError` → 502, `EntityTooSmall` → 422), unauthorized → 401/403, idempotent destroy.
- `spec/services/s3/multipart_upload_spec.rb` — service-level via `Aws.config[:s3] = { stub_responses: true }`. Cover key generation, part validation, contiguous part numbers, ACL setting, error wrapping.

---

### Modified (backend)

#### `config/routes.rb`

```ruby
namespace :uploads do
  resources :multipart, only: [:create, :destroy], param: :upload_id do
    post :parts,    on: :member
    post :complete, on: :member
  end
end
```

`FilesController` and `TreeImagesController` are **unchanged** for this PR. Backward compat preserved — single-shot still uses `/files/new` and `/tree_images/new`. DRYing up the duplicated presigned-POST logic is a follow-up.

---

## Operational Requirements (PR description must call these out)

1. **S3 bucket lifecycle rule on `bigtreecare`:** add `AbortIncompleteMultipartUpload: 7 days`. Reaps orphaned uploads from browser crashes / closed tabs. **Cannot live in code** — must be configured in AWS console or via separate IaC.
2. **CORS update on `bigtreecare`:** add `<AllowedMethod>PUT</AllowedMethod>` and **critically** `<ExposeHeader>ETag</ExposeHeader>`. Without `ExposeHeader: ETag`, the browser hides the ETag from JS and `complete` will fail with bogus part data. **Validate during smoke testing.**

---

## Reuse of Existing Code

- `signedUrlFormData` in `app/javascript/utils/awsS3Utils.js` — keep, still used for single-shot POST.
- `EventBus` (`app/javascript/store/eventBus.js`) — keep for global `API_ERROR` events; `UploadJob` does NOT emit through it (per-thumbnail state is local).
- `setupAxios()` in the mixin (lines 96-104) — must NOT run on S3 requests (would attach CSRF/JSON headers and break signature). New `uploadClient` calls bare `axios.request(...)`.
- `Aws::S3::Resource` setup — copy the pattern from `FilesController#new` into `S3::MultipartUpload`.
- `imageCompression` (`browser-image-compression`) — keep as-is, called from inside `UploadJob.start()`. Preserve the existing fallback-on-OOM path.

---

## Verification Plan

### Manual exercises (Chrome DevTools throttling)

| Scenario | Trigger | Expected |
|---|---|---|
| **Slow 3G upload** | DevTools → Network → "Slow 3G" | 1MB image: progress climbs slowly, completes. 12MB: 3 parts in flight, progress climbs in steps. |
| **Network drop mid-upload** | Start upload, switch to "Offline" 10s, then back | Progress halts, thumbnail flips red with Retry. Tap Retry → multipart resumes from failed part; single-shot restarts. |
| **Permanent offline at start** | DevTools "Offline" before picking file | Job lands in `retryableError` immediately with offline message. No retry storm. |
| **Auto-resume on reconnect** | offline → online while jobs are parked | All `retryableError` jobs auto-resume. `fatalError` jobs do not. |
| **Hung connection** | DevTools "Slow 3G" + pause; or aim at server that accepts but never responds | After 60s timeout (`ECONNABORTED`), classified retryable, backs off, retries. **`uploading` clears within ~60s, not "forever" — the bug we set out to fix.** |
| **Presigned URL expiry** | Time-travel system clock 20 min after start, before next part PUT (or debug flag injecting `?force-403=1`) | Client gets 403 + expiry signature, classifies as `expired`, refreshes part URLs transparently, retries. No user-visible error. |
| **5xx from S3** | DevTools right-click S3 request → "Block request URL" once | Retried with backoff up to 3 times, succeeds on 2nd. |
| **Hard fatal 4xx** | Tamper key/signature so S3 returns non-expiry 403 | Lands in `fatalError`. No Retry button. Telemetry captures. Submit blocked. |
| **Form submit while uploading** | Pick image, hit Submit before finish | Existing wait message shown. |
| **Form submit with errored image** | Fail an upload, leave it red, hit Submit | "1 image failed to upload — retry or remove…". Submit blocked. |
| **CORS smoke** | Watch Network during multipart | OPTIONS preflight 200; response includes `Access-Control-Expose-Headers: ETag`. |
| **ACL smoke** | After multipart `complete`, fetch URL anonymously | 200 OK (matches `public-read`; imgix CDN can fetch). |

### Unit tests for `UploadJob`

```
it: starts in idle
it: transitions idle → compressing → preparing → uploading → success on happy single-shot
it: transitions idle → preparing → uploading → finalizing → success on happy multipart
it: blocks .retry() unless status === retryableError
it: preserves done parts across retry (multipart)
it: refreshes part URLs when 403 expired comes back from S3
it: surfaces fatal classification (e.g. 400) without retrying
it: aborts mid-flight on .abort() and reaches cancelled
it: emits change on every transition
it: navigator.onLine === false at start lands in retryableError without HTTP attempt
it: retry budget = 3 attempts then fatalError; expired refreshes don't burn budget
```

### Unit tests for `uploadClient`

```
it: classifies network-with-no-response as retryable
it: classifies 408/429/5xx as retryable
it: classifies 4xx (other) as fatal
it: classifies 403+SignatureDoesNotMatch as expired
it: backoff is exponential with jitter ±30%
it: respects AbortSignal during backoff sleep
it: invokes onUploadProgress per attempt
```

### Unit tests for `multipartChunker`

```
it: produces partSize-sized chunks except the last
it: starts numbering at 1
it: handles file smaller than partSize (single chunk)
it: handles file exactly == partSize (single chunk)
```

### Backend specs (RSpec, Aws-stubbed)

```ruby
# Aws.config[:s3] = { stub_responses: true } in rails_helper or per-spec

# multipart_controller_spec
- POST /uploads/multipart returns upload_id and namespaced key matching bucket_name/Rails.env/UUID/filename
- POST /uploads/multipart/:id/parts validates part_numbers ∈ [1, 10000]
- POST /uploads/multipart/:id/complete forwards parts to S3 in order, returns canonical URL
- POST /uploads/multipart/:id/complete propagates Aws::S3::Errors::EntityTooSmall as 422
- DELETE /uploads/multipart/:id is idempotent (NoSuchUpload → 204)
- unauthorized request returns same status as FilesController#new
```

### Local commands

```bash
bundle exec rspec spec/controllers/uploads/multipart_controller_spec.rb spec/services/s3/multipart_upload_spec.rb
./bin/webpack-dev-server   # frontend dev server
rails s                    # Rails server
# Open Tree Images "Add New" modal → DevTools throttle to Slow 3G → upload 12MB image
# Toggle Offline mid-upload → verify Retry button appears and resumes successfully
```

---

## Risks & Tradeoffs

1. **Axios bump 0.20 → 1.7** is project-wide. All callers verified to use only `get/post/put/delete`. Smoke-test admin pages after bump. Worst case, fall back to legacy `CancelToken` API and stay on 0.20.
2. **5MB minimum non-final part size (S3 hard rule).** Threshold for going multipart is therefore 5 MiB on the **post-compression** blob — check `compressedBlob.size`, not the input file.
3. **Maximum 10,000 parts.** With 5 MiB parts, max object = 50 GB. Nowhere near for tree photos; non-issue.
4. **CORS `ExposeHeader: ETag` is critical.** Easy to miss. Verification plan flags it explicitly.
5. **`navigator.onLine` is unreliable on iOS Safari** (returns true on captive portals). Treat it as an optimization, not source of truth — the timeout+retry machinery is the real defense.
6. **Browser image compression runs in a Web Worker** and can OOM on low-RAM phones. `compressFile` (`upload.vue:147`) catches and falls back to original — preserve that path in `UploadJob.start()`. Don't make worker failure fatal.
7. **Multipart concurrency = 3** is a guess. If field reports show 3 still saturates a weak link, drop to 2 — single constant in `uploadClient.js`, not threaded through.
8. **Resume across page reloads is NOT in scope.** Closing the tab orphans the multipart upload (lifecycle rule reaps it after 7 days). `localStorage`-persisted `uploadId` + parts manifest would be a follow-up milestone.
9. **Sentry frontend wiring is NOT in this PR** — telemetry shim today logs to console. Adding `@sentry/vue` later is one file's worth of work given the shim interface.
10. **`acl: 'public-read'`** must be set on `create_multipart_upload`, not per-part. If forgotten, imgix CDN can't fetch the object and downstream image rendering 403s. Add an integration test that fetches the URL anonymously after `complete`.
11. **The XML response parser (`parseImageUploadResponse`) is silent on parse failure.** This PR keeps single-shot on POST/XML for tightness; just wraps `parseString` in try/catch that throws a typed `XmlParseError`. The state machine handles it as fatal. Switching single-shot to PUT + a Rails endpoint that returns the URL deterministically is a nice-to-have follow-up.
12. **Rails test coverage in this repo is thin.** New controller specs + service specs will set the pattern. Reviewers should be ready for "this adds a lot of test infra for one feature" — push back if asked to skip them.
13. **No Jest config in the repo.** New services are framework-free plain JS — runnable under `node --test`. Adding Jest is a separate decision; doesn't change the design.

---

## Implementation Order (suggested)

1. **Backend first** — `S3::MultipartUpload` service + `Uploads::MultipartController` + routes + specs. Lands cleanly without touching frontend; verifies CORS and lifecycle rule via curl/Postman before a single line of Vue code.
2. **CORS + lifecycle rule** — operational changes in AWS console. Without these, frontend work can't be tested.
3. **Frontend services** — `uploadClient.js`, `UploadJob.js`, `multipartChunker.js`, `uploadTelemetry.js`, `uploadValidation.js` + their unit tests. Standalone, no Vue dependency.
4. **Frontend axios bump** — `axios@^1.7` + smoke test.
5. **`uploadItem.vue` and `uploadList.vue`** — the new canonical components.
6. **Migrate consumers** — `singleUploader.vue` → wrapper, `upload.vue` / `imageUpload.vue` / `multiUpload.vue` / `tree_images/forms/uploader.vue` → use `UploadJob`. `addNew.vue` and `receipts/create.vue` → use `uploadGuard()`.
7. **Mixin cleanup** — delete `axiosImagePost` and `axiosBase64ImagePost` from `axiosMixin.js`.
8. **End-to-end manual verification** per the table above.

---

## Critical Files

**New:**
- `app/javascript/services/uploadClient.js`
- `app/javascript/services/UploadJob.js`
- `app/javascript/services/multipartChunker.js`
- `app/javascript/services/uploadTelemetry.js`
- `app/javascript/utils/uploadValidation.js`
- `app/javascript/components/file/uploadItem.vue`
- `app/javascript/components/file/uploadList.vue`
- `app/controllers/uploads/multipart_controller.rb`
- `app/services/s3/multipart_upload.rb`
- `spec/controllers/uploads/multipart_controller_spec.rb`
- `spec/services/s3/multipart_upload_spec.rb`

**Modified:**
- `app/javascript/mixins/axiosMixin.js`
- `app/javascript/components/file/actions/singleUploader.vue`
- `app/javascript/components/file/actions/upload.vue`
- `app/javascript/components/file/actions/imageUpload.vue`
- `app/javascript/components/file/actions/multiUpload.vue`
- `app/javascript/components/tree_images/forms/uploader.vue`
- `app/javascript/components/tree_images/actions/addNew.vue`
- `app/javascript/components/receipts/actions/create.vue`
- `app/javascript/utils/awsS3Utils.js`
- `config/routes.rb`
- `package.json` (axios bump)
