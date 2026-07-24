import axios from 'axios';
import { putWithRetry, postWithRetry, classify, UploadCancelled, UploadFatal, UploadUrlExpired } from './uploadClient.js';
import { chunksFor } from './multipartChunker.js';
import { breadcrumb, captureException } from './uploadTelemetry.js';

const MULTIPART_THRESHOLD = 5 * 1024 * 1024  // 5 MiB
const PART_SIZE          = 5 * 1024 * 1024;  // 5 MiB
const PART_CONCURRENCY   = 3;
const PART_URL_REFRESH_MS = 12 * 60 * 1000;  // refresh before 15-min expiry

// Indefinite, capped, jittered backoff for retryable failures.
const RETRY_BASE_MS = 1000;
const RETRY_CAP_MS  = 60 * 1000;

// Statuses that are not yet finished (drive on hydrate / online).
// 'pendingAssociation' (S3 done, placeholder/URL not yet written) and
// 'awaitingTarget' (S3 done, new-quote target not yet resolved) are orthogonal
// not-yet-done states — background work, not errors.
export const NON_TERMINAL = new Set([
  'idle', 'compressing', 'preparing', 'uploading', 'finalizing',
  'retryableError', 'pendingAssociation', 'awaitingTarget',
]);
// 'success' = generic upload finished (no association). 'done' = associating
// upload finished (S3 + DB row written).
export const TERMINAL = new Set(['success', 'done', 'fatalError', 'cancelled']);

const uuid = () =>
  (typeof crypto !== 'undefined' && crypto.randomUUID)
    ? crypto.randomUUID()
    : `${Date.now()}-${Math.random().toString(36).slice(2)}`;

// Default IO collaborators. All overridable via options.client so the job can
// be unit-tested without touching the network or browser-only modules. The
// browser-coupled helpers (S3 form-data, image compression) are imported
// lazily so this module loads in a plain Node test runner.
function defaultClient() {
  let _awsUtils = null;
  const awsUtils = async () => (_awsUtils ??= await import('../utils/awsS3Utils.js'));

  return {
    railsGet:    (path, params = {}) => axios.get(path, { params, withCredentials: true }),
    railsPost:   (path, data = {})   => axios.post(path, data, { withCredentials: true }),
    railsDelete: (path)              => axios.delete(path, { withCredentials: true }),
    postWithRetry,
    putWithRetry,
    chunksFor,
    // Idempotent association on client_upload_id. Returns the serialized
    // tree_image (incl. id + ready). Omitting image_url creates/keeps the
    // pending placeholder; passing it fills the URL.
    associate: async (params) => {
      const resp = await axios.post('/tree_images/associate', params, { withCredentials: true });
      return resp.data?.tree_image ?? resp.data;
    },
    deleteTreeImage: (id, estimateId) =>
      axios.delete(`/tree_images/${id}${estimateId != null ? `?estimate_id=${estimateId}` : ''}`, { withCredentials: true }),
    signedUrlFormData:        async (fields, blob) => (await awsUtils()).signedUrlFormData(fields, blob),
    parseImageUploadResponse: async (resp)         => (await awsUtils()).parseImageUploadResponse(resp),
    compressImage:            defaultCompressImage,
  };
}

// Resize (canvas) + compress an image, falling back to the original on failure.
// Mirrors the previous upload.vue behaviour; browser-only, lazily loaded.
async function defaultCompressImage(file) {
  try {
    const { default: imageCompression } = await import('browser-image-compression');
    const resized = await resizeImage(file);
    return await imageCompression(resized, { maxSizeMB: 1, maxWidthOrHeight: 1024, useWebWorker: true });
  } catch (e) {
    console.warn('Image compression failed, uploading original:', e);
    return file;
  }
}

function resizeImage(file) {
  return new Promise((resolve, reject) => {
    const MAX_DIM = 1920;
    const img = new Image();
    const url = URL.createObjectURL(file);

    img.onload = () => {
      URL.revokeObjectURL(url);
      if (img.width <= MAX_DIM && img.height <= MAX_DIM) { resolve(file); return; }
      let { width, height } = img;
      if (width > height) { height = Math.round(height * MAX_DIM / width); width = MAX_DIM; }
      else                { width  = Math.round(width * MAX_DIM / height); height = MAX_DIM; }
      const canvas = document.createElement('canvas');
      canvas.width = width; canvas.height = height;
      canvas.getContext('2d').drawImage(img, 0, 0, width, height);
      canvas.toBlob(blob => {
        if (!blob) { reject(new Error('Canvas resize failed')); return; }
        resolve(new File([blob], file.name, { type: file.type }));
      }, file.type);
    };
    img.onerror = () => { URL.revokeObjectURL(url); reject(new Error('Image load failed')); };
    img.src = url;
  });
}

export class UploadJob {
  constructor(file, options = {}) {
    this.id    = options.id ?? uuid();
    // Stable across retries/resume; the idempotency key for association.
    this.clientUploadId = options.clientUploadId ?? uuid();
    this.file  = file;
    this.options = {
      compress:    true,
      bucketName:  options.bucketName ?? 'documents',
      presignPath: options.presignPath ?? '/files/new',
      ...options,
    };

    // Target descriptor describing how this file gets associated (Chunk 6).
    this.target = options.target ?? null;

    this.status   = options.status ?? 'idle';
    this.progress = options.progress ?? 0;
    this.error    = options.error ?? null;
    this.url      = options.url ?? null;
    this.attempts = options.attempts ?? 0;

    // Two-track association state (persisted, so resume converges without a
    // duplicate row). s3Url: the object is in S3. placeholderId: the DB row
    // exists. The job is 'done' only once both are true and the URL is written.
    this.s3Url         = options.s3Url ?? null;
    this.placeholderId = options.placeholderId ?? null;
    this._placeholderInFlight = false;
    this._fillInFlight = false;
    // True while pause() is aborting in-flight work, so the resulting
    // UploadCancelled is treated as "pause" (→ retryableError, resumable) and
    // NOT as a genuine user cancel (→ cancelled, terminal).
    this._pausing = false;
    this.createdAt = options.createdAt ?? Date.now();
    this.updatedAt = options.updatedAt ?? this.createdAt;

    // multipart state
    this._uploadId = options.multipart?.uploadId ?? null;
    this._key      = options.multipart?.key ?? null;
    this._parts    = (options.multipart?.parts ?? []).map(p => ({ ...p, blob: null }));

    // Injectable seams (overridable for tests).
    this.adapter        = options.adapter ?? null;
    this._client        = { ...defaultClient(), ...(options.client ?? {}) };
    this._now           = options.now ?? (() => Date.now());
    this._isOnline      = options.isOnline ?? (() => (typeof navigator === 'undefined' || navigator.onLine !== false));
    this._setTimeoutFn  = options.setTimeoutFn ?? ((fn, ms) => setTimeout(fn, ms));
    this._clearTimeoutFn = options.clearTimeoutFn ?? ((t) => clearTimeout(t));
    this._random        = options.random ?? Math.random;

    this._abort = new AbortController();
    this._listeners = new Set();
    this._retryTimer = null;
    this._lastProgressPersist = 0;
    // Lazily-created optimistic preview objectURL (see localPreview()).
    this._previewUrl = null;
  }

  on(fn)  { this._listeners.add(fn); return () => this._listeners.delete(fn); }
  _emit() { for (const fn of this._listeners) fn(this); }

  // Optimistic local preview of the file as an objectURL, created on demand
  // and cached. Only the browser holding the blob can produce one — so only
  // the uploading user sees their real image while a row is still pending;
  // every other viewer keeps the placeholder. Survives reload because the blob
  // is persisted and re-attached on reconstruct. Browser-only: returns null
  // under the Node test runner (no URL.createObjectURL).
  localPreview() {
    if (this._previewUrl) return this._previewUrl;
    if (!this.file || typeof URL === 'undefined' || !URL.createObjectURL) return null;
    this._previewUrl = URL.createObjectURL(this.file);
    return this._previewUrl;
  }

  // Release the preview objectURL. Owned here (not by any component) so its
  // lifetime tracks the job, not whichever view happens to be mounted.
  revokePreview() {
    if (this._previewUrl && typeof URL !== 'undefined' && URL.revokeObjectURL) {
      URL.revokeObjectURL(this._previewUrl);
    }
    this._previewUrl = null;
  }

  _serializeMultipart() {
    if (!this._uploadId) return null;
    return {
      uploadId: this._uploadId,
      key:      this._key,
      // Blobs are re-derived from the persisted file on resume; don't store them.
      parts:    this._parts.map(({ partNumber, status, etag, urlIssuedAt }) => ({ partNumber, status, etag, urlIssuedAt })),
    };
  }

  // Write-through: every state transition is persisted immediately.
  _persist(extra = {}) {
    if (!this.adapter) return;
    this.adapter.patch(this.id, {
      status:        this.status,
      progress:      this.progress,
      error:         this.error,
      url:           this.url,
      s3Url:         this.s3Url,
      placeholderId: this.placeholderId,
      attempts:      this.attempts,
      target:        this.target,
      multipart:     this._serializeMultipart(),
      updatedAt:     this.updatedAt,
      ...extra,
    }).catch(() => { /* persistence is best-effort */ });
  }

  // Progress fires often; persist it at most ~1/s so we don't thrash storage.
  _persistProgress() {
    if (!this.adapter) return;
    const t = this._now();
    if (t - this._lastProgressPersist < 1000) return;
    this._lastProgressPersist = t;
    this.updatedAt = t;
    this.adapter.patch(this.id, { progress: this.progress, updatedAt: t }).catch(() => {});
  }

  _setState(status, extra = {}) {
    this.status = status;
    Object.assign(this, extra);
    this.updatedAt = this._now();
    breadcrumb('UploadJob', status, { id: this.id, file: this.file?.name });
    this._persist();
    this._emit();
  }

  _onProgress(pct) {
    this.progress = pct;
    this._persistProgress();
    this._emit();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  async start() {
    if (this.status !== 'idle') return;
    // The placeholder track runs in parallel with the S3 upload (it only does
    // anything once the target is resolved). Both converge in _tryFinish.
    const placeholder = this._kickPlaceholder();
    await this._attempt(false);
    await placeholder;
    await this._tryFinish();
  }

  async retry() {
    if (this.status !== 'retryableError') return;
    await this._attempt(true);
    await this._tryFinish();
  }

  // Resume from whatever state a hydrated/paused job is in. Called by the
  // manager on app boot and on the 'online' event.
  resume() {
    if (this.status === 'done' || this.status === 'success' || this.status === 'cancelled') return;

    // S3 already finished (persisted s3Url): don't re-upload — just drive the
    // association tracks to completion.
    if (this._associates() && this.s3Url) {
      const placeholder = this._kickPlaceholder();
      return Promise.resolve(placeholder).then(() => this._tryFinish());
    }

    if (this.status === 'idle') return this.start();
    if (this.status === 'retryableError') {
      this._clearRetryTimer();
      return this.retry();
    }
    // uploading/preparing/etc. left mid-flight by a reload: re-drive it.
    if (NON_TERMINAL.has(this.status)) {
      this.status = 'retryableError';
      return this.retry();
    }
  }

  async _attempt(isRetry) {
    this._abort = new AbortController();
    this.error = null;
    this._pausing = false;
    this._clearRetryTimer();

    try {
      if (isRetry && this._uploadId) {
        // Resume an in-flight multipart upload.
        this._setState('uploading');
        try {
          await this._driveMultipart();
        } catch (err) {
          if (this._isExpiredMultipart(err)) {
            breadcrumb('UploadJob', 'multipart-expired-restart', { id: this.id });
            this._resetMultipart();
            await this._startFresh();
          } else {
            throw err;
          }
        }
      } else if (isRetry && this._compressedBlob) {
        // Single-shot resume: restart the whole blob (already compressed).
        await this._uploadBlob(this._compressedBlob);
      } else {
        await this._startFresh();
      }
    } catch (err) {
      this._onError(err);
    }
  }

  async _startFresh() {
    let blob = this.file;
    if (this.options.compress && this._isImage(this.file)) {
      this._setState('compressing');
      blob = await this._client.compressImage(this.file);
    }
    this._compressedBlob = blob;
    await this._uploadBlob(blob);
  }

  async _uploadBlob(blob) {
    if (blob.size <= MULTIPART_THRESHOLD) {
      await this._singleShot(blob);
    } else {
      await this._multipart(blob);
    }
  }

  _isImage(file) {
    return !!(file?.type && file.type.match(/image\/*/));
  }

  _onError(err) {
    if (err instanceof UploadCancelled || err?.name === 'UploadCancelled') {
      this._onCancelled();
      return;
    }
    captureException(err, { jobId: this.id });

    if (err instanceof UploadFatal || err?.name === 'UploadFatal') {
      this._setState('fatalError', { error: { message: err.message || 'Upload failed.', retryable: false } });
      return;
    }

    // Retryable: schedule indefinitely with capped backoff.
    this._scheduleRetry();
  }

  // An UploadCancelled can come from pause() (offline) or from a genuine
  // abort()/remove(). Only the latter is terminal; a pause stays in
  // retryableError so the manager resumes it on reconnect.
  _onCancelled() {
    if (this._pausing) {
      this._pausing = false;
      return;  // pause() already set retryableError; leave it resumable
    }
    this._setState('cancelled');
  }

  // Capped, jittered exponential backoff. Pure + deterministic with an
  // injected `random`, so tests can assert growth and the cap.
  _retryDelay(attempt) {
    const exp = Math.min(RETRY_CAP_MS, RETRY_BASE_MS * 2 ** (attempt - 1));
    const delta = exp * 0.3;
    return Math.round(exp - delta + this._random() * 2 * delta);
  }

  _scheduleRetry() {
    this.attempts += 1;
    this._setState('retryableError', { error: { message: 'Upload failed — retrying.', retryable: true } });

    // Offline: don't tight-loop. Wait for the manager's 'online' → resume().
    if (!this._isOnline()) return;

    const delay = this._retryDelay(this.attempts);
    this._clearRetryTimer();
    this._retryTimer = this._setTimeoutFn(() => {
      this._retryTimer = null;
      return this.retry();  // returned so tests can await; setTimeout ignores it
    }, delay);
  }

  _clearRetryTimer() {
    if (this._retryTimer != null) {
      this._clearTimeoutFn(this._retryTimer);
      this._retryTimer = null;
    }
  }

  abort() {
    this._clearRetryTimer();
    this._abort.abort();
    if (this._uploadId) {
      this._client.railsDelete(`/uploads/multipart/${this._uploadId}?key=${encodeURIComponent(this._key)}`).catch(() => {});
    }
    this._setState('cancelled');
  }

  pause() {
    this._clearRetryTimer();
    // Flag so the abort below is recognised as a pause, not a cancel.
    this._pausing = true;
    this._abort.abort();
    this._setState('retryableError', {
      error: { message: 'Upload paused — no network connection.', retryable: true },
    });
  }

  _isExpiredMultipart(err) {
    if (!err) return false;
    if (err instanceof UploadUrlExpired || err.name === 'UploadUrlExpired') return true;
    const status = err.response?.status ?? err.status;
    if (status === 403 || status === 404) return true;
    const text = `${err.message || ''} ${JSON.stringify(err.response?.data ?? '')}`;
    return /NoSuchUpload/i.test(text);
  }

  _resetMultipart() {
    this._uploadId = null;
    this._key      = null;
    this._parts    = [];
  }

  // ---------------------------------------------------------------------------
  // Two-track association (placeholder-first)
  // ---------------------------------------------------------------------------

  // True when this upload must be linked to a tree_image DB row.
  _associates() {
    return !!(this.target && this.target.type === 'tree_image');
  }

  // True when we know the real estimate/tree to attach to.
  _targetResolved() {
    return this._associates() && this.target.pending !== true && this.target.estimate_id != null;
  }

  // Called when the S3 object lands. For a generic upload that's the end
  // ('success'). For an associating upload it kicks the URL-fill track.
  async _onS3Complete(url) {
    this.s3Url = url;
    this.url   = url;
    this.progress = 100;

    if (!this._associates()) {
      this._setState('success', { url, progress: 100 });
      return;
    }

    // A parallel association track may have already fataled/cancelled — don't
    // clobber that terminal state with a pending one.
    if (this.status === 'fatalError' || this.status === 'cancelled') {
      this._persist();
      return;
    }

    // S3 done but DB row not yet written. Sit in pendingAssociation when the
    // target is known, awaitingTarget when it isn't (new-quote pre-submit).
    this._setState(this._targetResolved() ? 'pendingAssociation' : 'awaitingTarget');
    await this._tryFinish();
  }

  // Set when the manager rewires a new-quote job to its real tree at submit.
  async resolveTarget(target) {
    this.target = target;
    this._persist();
    this._emit();
    await this._kickPlaceholder();
    await this._tryFinish();
  }

  // Ensure-placeholder track: as soon as the target is resolved, create the
  // pending row (no image_url). Idempotent on client_upload_id.
  _kickPlaceholder() {
    if (!this._targetResolved() || this.placeholderId || this._placeholderInFlight) {
      return Promise.resolve();
    }
    this._placeholderInFlight = true;
    return (async () => {
      try {
        // The S3-phase status is left untouched; association is orthogonal.
        const treeImage = await this._retryingAssociate(null);
        this.placeholderId = treeImage?.id ?? this.placeholderId;
        this._persist();
        this._emit();
        await this._tryFinish();
      } catch (err) {
        this._onAssociationError(err);
      } finally {
        this._placeholderInFlight = false;
      }
    })();
  }

  // Fill-URL track: once both the row and the S3 URL exist, write the URL and
  // the job is done. Idempotent + order-independent with the placeholder track.
  async _tryFinish() {
    if (!this._associates() || this._fillInFlight) return;
    if (this.status === 'done' || this.status === 'fatalError' || this.status === 'cancelled') return;
    if (!(this.placeholderId && this.s3Url)) return;

    this._fillInFlight = true;
    try {
      await this._retryingAssociate(this.s3Url);
      this._setState('done', { url: this.s3Url, progress: 100 });
    } catch (err) {
      this._onAssociationError(err);
    } finally {
      this._fillInFlight = false;
    }
  }

  // POST /tree_images/associate, retrying retryable failures indefinitely with
  // capped backoff; throws on fatal (validation/auth/4xx) and on cancel.
  async _retryingAssociate(imageUrl) {
    let attempt = 0;
    for (;;) {
      if (this._abort.signal.aborted) throw new UploadCancelled();
      try {
        return await this._client.associate({
          client_upload_id: this.clientUploadId,
          estimate_id:      this.target.estimate_id,
          tree_id:          this.target.tree_id,
          ...(imageUrl != null ? { image_url: imageUrl } : {}),
        });
      } catch (err) {
        const kind = classify(err);
        if (kind === 'cancelled') throw new UploadCancelled();
        if (kind === 'fatal') throw (err instanceof UploadFatal ? err : new UploadFatal(err.message || 'Association failed.'));
        // retryable / expired → wait and try again, forever
        attempt += 1;
        await this._delay(this._retryDelay(attempt));
      }
    }
  }

  _delay(ms) {
    return new Promise(resolve => this._setTimeoutFn(resolve, ms));
  }

  _onAssociationError(err) {
    if (err instanceof UploadCancelled || err?.name === 'UploadCancelled') {
      this._onCancelled();
      return;
    }
    captureException(err, { jobId: this.id, phase: 'associate' });
    this._setState('fatalError', { error: { message: err.message || 'Could not save image.', retryable: false } });
  }

  // Destroy the pending placeholder row (called by the manager on remove), so
  // a removed-while-pending image leaves no dangling row.
  async deletePlaceholder() {
    if (!this.placeholderId) return;
    try {
      await this._client.deleteTreeImage(this.placeholderId, this.target?.estimate_id);
    } catch (e) {
      // best-effort
    }
    this.placeholderId = null;
  }

  // ---------------------------------------------------------------------------
  // Single-shot presigned POST
  // ---------------------------------------------------------------------------

  async _singleShot(blob) {
    this._compressedBlob = blob;
    this._setState('preparing');

    const resolveTarget = async () => {
      const resp = await this._client.railsGet(this.options.presignPath, {
        bucket_name: this.options.bucketName,
        filename: this.file.name,
      });
      const formData = await this._client.signedUrlFormData(resp.data.fields, blob);
      return { url: resp.data.url, formData };
    };

    this._setState('uploading');
    const response = await this._client.postWithRetry({
      resolveTarget,
      onProgress: pct => this._onProgress(pct),
      signal: this._abort.signal,
    });

    const url = await this._client.parseImageUploadResponse(response);
    await this._onS3Complete(url);
  }

  // ---------------------------------------------------------------------------
  // Multipart upload
  // ---------------------------------------------------------------------------

  async _multipart(blob) {
    this._compressedBlob = blob;
    this._setState('preparing');

    const initResp = await this._client.railsPost('/uploads/multipart', {
      bucket_name:  this.options.bucketName,
      filename:     this.file.name,
      content_type: blob.type || 'application/octet-stream',
    });

    this._uploadId = initResp.data.upload_id;
    this._key      = initResp.data.key;

    this._parts = this._client.chunksFor(blob, PART_SIZE).map(c => ({
      partNumber:   c.partNumber,
      blob:         c.blob,
      status:       'pending',
      etag:         null,
      urlIssuedAt:  null,
    }));

    this._setState('uploading');
    await this._driveMultipart();
  }

  // Re-hydrate part blobs from the file when resuming a persisted multipart.
  _ensurePartBlobs() {
    if (this._parts.length && this._parts.some(p => p.blob == null) && this._compressedBlob) {
      const fresh = this._client.chunksFor(this._compressedBlob, PART_SIZE);
      for (const part of this._parts) {
        const match = fresh.find(c => c.partNumber === part.partNumber);
        if (match) part.blob = match.blob;
      }
    }
  }

  async _driveMultipart() {
    this._ensurePartBlobs();
    const pending = this._parts.filter(p => p.status !== 'done');
    let cursor = 0;
    let activeCount = 0;
    let firstError = null;

    await new Promise((resolve, reject) => {
      const next = () => {
        if (firstError) return;
        if (cursor >= pending.length && activeCount === 0) { resolve(); return; }
        while (activeCount < PART_CONCURRENCY && cursor < pending.length) {
          const part = pending[cursor++];
          activeCount++;
          this._uploadPart(part)
            .then(() => {
              activeCount--;
              this._updateProgress();
              next();
            })
            .catch(err => {
              activeCount--;
              firstError = err;
              reject(err);
            });
        }
      };
      next();
    });

    this._setState('finalizing');

    const completedParts = this._parts.map(p => ({ part_number: p.partNumber, etag: p.etag }));
    const completeResp = await this._client.railsPost(`/uploads/multipart/${this._uploadId}/complete`, {
      key:   this._key,
      parts: completedParts,
    });

    await this._onS3Complete(completeResp.data.url);
  }

  async _uploadPart(part) {
    const needsUrlRefresh = () =>
      !part.urlIssuedAt || (Date.now() - part.urlIssuedAt) > PART_URL_REFRESH_MS;

    let cachedUrl = null;

    const resolveTarget = async () => {
      if (!cachedUrl || needsUrlRefresh()) {
        const resp = await this._client.railsPost(`/uploads/multipart/${this._uploadId}/parts`, {
          key:          this._key,
          part_numbers: [part.partNumber],
        });
        cachedUrl = resp.data.parts[0].url;
        part.urlIssuedAt = Date.now();
      }
      return { url: cachedUrl };
    };

    const response = await this._client.putWithRetry({
      resolveTarget,
      body:   part.blob,
      signal: this._abort.signal,
      onProgress: () => {},  // individual part progress tracked via _updateProgress
    });

    part.etag   = response.headers.etag;
    part.status = 'done';
  }

  _updateProgress() {
    const done = this._parts.filter(p => p.status === 'done').length;
    this.progress = Math.round((done / this._parts.length) * 100);
    this._persistProgress();
    this._emit();
  }
}
