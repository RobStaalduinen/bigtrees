import axios from 'axios';
import imageCompression from 'browser-image-compression';
import { putWithRetry, postWithRetry, UploadCancelled, UploadFatal } from './uploadClient';
import { chunksFor } from './multipartChunker';
import { signedUrlFormData, parseImageUploadResponse } from '../utils/awsS3Utils';
import { breadcrumb, captureException } from './uploadTelemetry';

const MULTIPART_THRESHOLD = 5 * 1024 * 1024  // 5 MiB
const PART_SIZE          = 5 * 1024 * 1024;  // 5 MiB
const PART_CONCURRENCY   = 3;
const PART_URL_REFRESH_MS = 12 * 60 * 1000;  // refresh before 15-min expiry

// Rails API client — inherits CSRF/org headers set by setupAxios().
function railsGet(path, params = {}) {
  return axios.get(path, { params, withCredentials: true });
}

function railsPost(path, data = {}) {
  return axios.post(path, data, { withCredentials: true });
}

function railsDelete(path) {
  return axios.delete(path, { withCredentials: true });
}

export class UploadJob {
  constructor(file, options = {}) {
    this.id      = options.id ?? (typeof crypto !== 'undefined' ? crypto.randomUUID() : Math.random().toString(36).slice(2));
    this.file    = file;
    this.options = {
      compress:    true,
      bucketName:  options.bucketName ?? 'documents',
      presignPath: options.presignPath ?? '/files/new',
      ...options,
    };

    this.status   = 'idle';
    this.progress = 0;
    this.error    = null;
    this.url      = null;

    // multipart state
    this._uploadId = null;
    this._key      = null;
    this._parts    = [];  // [{ partNumber, status, etag, blob, urlIssuedAt }]

    this._abort = new AbortController();
    this._listeners = new Set();
  }

  on(fn)  { this._listeners.add(fn); return () => this._listeners.delete(fn); }
  _emit() { for (const fn of this._listeners) fn(this); }

  _setState(status, extra = {}) {
    this.status = status;
    Object.assign(this, extra);
    breadcrumb('UploadJob', status, { id: this.id, file: this.file?.name });
    this._emit();
  }

  async start() {
    if (this.status !== 'idle') return;
    this._abort = new AbortController();

    try {
      let blob = this.file;

      if (this.options.compress && this.file.type.match(/image\/*/)) {
        this._setState('compressing');
        blob = await this._compress(this.file);
      }

      if (blob.size <= MULTIPART_THRESHOLD) {
        await this._singleShot(blob);
      } else {
        await this._multipart(blob);
      }
    } catch (err) {
      if (err instanceof UploadCancelled || err.name === 'UploadCancelled') {
        this._setState('cancelled');
        return;
      }
      captureException(err, { jobId: this.id });
      const retryable = !(err instanceof UploadFatal);
      this._setState('retryableError', {
        error: { message: retryable ? 'Upload failed — check your connection.' : (err.message || 'Upload failed.'), retryable },
      });
      if (err instanceof UploadFatal) {
        this._setState('fatalError', { error: { message: err.message || 'Upload failed.', retryable: false } });
      }
    }
  }

  async retry() {
    if (this.status !== 'retryableError') return;
    this._abort = new AbortController();
    this.error = null;
    this._setState('uploading');

    try {
      if (this._uploadId) {
        // resume multipart — re-upload only failed/pending parts
        await this._driveMultipart();
      } else {
        // single-shot: restart the whole blob
        await this._singleShot(this._compressedBlob ?? this.file);
      }
    } catch (err) {
      if (err instanceof UploadCancelled || err.name === 'UploadCancelled') {
        this._setState('cancelled');
        return;
      }
      captureException(err, { jobId: this.id, retry: true });
      if (err instanceof UploadFatal) {
        this._setState('fatalError', { error: { message: err.message || 'Upload failed.', retryable: false } });
      } else {
        this._setState('retryableError', { error: { message: 'Upload failed — check your connection.', retryable: true } });
      }
    }
  }

  abort() {
    this._abort.abort();
    if (this._uploadId) {
      railsDelete(`/uploads/multipart/${this._uploadId}?key=${encodeURIComponent(this._key)}`).catch(() => {});
    }
    this._setState('cancelled');
  }

  pause() {
    this._abort.abort();
    this._setState('retryableError', {
      error: { message: 'Upload paused — no network connection.', retryable: true },
    });
  }

  // -------------------------------------------------------------------------
  // Single-shot presigned POST
  // -------------------------------------------------------------------------

  async _singleShot(blob) {
    this._compressedBlob = blob;
    this._setState('preparing');

    const resolveTarget = async () => {
      const resp = await railsGet(this.options.presignPath, {
        bucket_name: this.options.bucketName,
        filename: this.file.name,
      });
      const formData = signedUrlFormData(resp.data.fields, blob);
      return { url: resp.data.url, formData };
    };

    this._setState('uploading');
    const response = await postWithRetry({
      resolveTarget,
      onProgress: pct => { this.progress = pct; this._emit(); },
      signal: this._abort.signal,
    });

    const url = parseImageUploadResponse(response);
    this._setState('success', { url, progress: 100 });
  }

  // -------------------------------------------------------------------------
  // Multipart upload
  // -------------------------------------------------------------------------

  async _multipart(blob) {
    this._compressedBlob = blob;
    this._setState('preparing');

    const initResp = await railsPost('/uploads/multipart', {
      bucket_name:  this.options.bucketName,
      filename:     this.file.name,
      content_type: blob.type || 'application/octet-stream',
    });

    this._uploadId = initResp.data.upload_id;
    this._key      = initResp.data.key;

    this._parts = chunksFor(blob, PART_SIZE).map(c => ({
      partNumber:   c.partNumber,
      blob:         c.blob,
      status:       'pending',
      etag:         null,
      urlIssuedAt:  null,
    }));

    this._setState('uploading');
    await this._driveMultipart();
  }

  async _driveMultipart() {
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
    const completeResp = await railsPost(`/uploads/multipart/${this._uploadId}/complete`, {
      key:   this._key,
      parts: completedParts,
    });

    this._setState('success', { url: completeResp.data.url, progress: 100 });
  }

  async _uploadPart(part) {
    const needsUrlRefresh = () =>
      !part.urlIssuedAt || (Date.now() - part.urlIssuedAt) > PART_URL_REFRESH_MS;

    let cachedUrl = null;

    const resolveTarget = async () => {
      if (!cachedUrl || needsUrlRefresh()) {
        const resp = await railsPost(`/uploads/multipart/${this._uploadId}/parts`, {
          key:          this._key,
          part_numbers: [part.partNumber],
        });
        cachedUrl = resp.data.parts[0].url;
        part.urlIssuedAt = Date.now();
      }
      return { url: cachedUrl };
    };

    const response = await putWithRetry({
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
    this._emit();
  }

  // -------------------------------------------------------------------------
  // Compression with OOM fallback (mirrors upload.vue:132-151)
  // -------------------------------------------------------------------------

  async _compress(file) {
    try {
      const resized = await this._resizeImage(file);
      return await imageCompression(resized, { maxSizeMB: 1, maxWidthOrHeight: 1024, useWebWorker: true });
    } catch (e) {
      console.warn('Image compression failed, uploading original:', e);
      return file;
    }
  }

  _resizeImage(file) {
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
}
