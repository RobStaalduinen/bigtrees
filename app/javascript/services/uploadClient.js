import axios from 'axios';
import { breadcrumb, captureException } from './uploadTelemetry';

// Dedicated S3 client — no CSRF/JSON/org headers that would interfere with
// presigned URL signatures or cause CORS preflight failures.
const _s3 = axios.create();
_s3.defaults.headers.common = {};
delete _s3.defaults.headers.post['Content-Type'];

const DEFAULT_TIMEOUT_MS = 60_000;
const MAX_ATTEMPTS = 3;
const BASE_BACKOFF_MS = 500;
const RETRYABLE_STATUSES = new Set([408, 425, 429, 500, 502, 503, 504]);

export class UploadCancelled extends Error {
  constructor() { super('Upload cancelled'); this.name = 'UploadCancelled'; }
}

export class UploadFatal extends Error {
  constructor(message) { super(message); this.name = 'UploadFatal'; }
}

export class UploadUrlExpired extends Error {
  constructor() { super('Presigned URL expired'); this.name = 'UploadUrlExpired'; }
}

function jitter(ms) {
  const delta = ms * 0.3;
  return ms - delta + Math.random() * 2 * delta;
}

export function classify(error) {
  if (axios.isCancel(error)) return 'cancelled';
  if (error.name === 'UploadCancelled' || error.code === 'ERR_CANCELED') return 'cancelled';
  if (error.code === 'ECONNABORTED') return 'retryable';
  if (!error.response) return 'retryable';
  const { status, data } = error.response;
  if (status === 403 && /Expired|SignatureDoesNotMatch|RequestTimeTooSkewed/i.test(String(data))) {
    return 'expired';
  }
  if (RETRYABLE_STATUSES.has(status)) return 'retryable';
  return 'fatal';
}

async function sleep(ms, signal) {
  return new Promise((resolve, reject) => {
    const t = setTimeout(resolve, ms);
    signal.addEventListener('abort', () => {
      clearTimeout(t);
      reject(new UploadCancelled());
    }, { once: true });
  });
}

async function withRetry({ resolveTarget, makeRequest, signal, onProgress, timeoutMs = DEFAULT_TIMEOUT_MS }) {
  let target = await resolveTarget();
  let lastErr;
  let attempt = 1;

  while (attempt <= MAX_ATTEMPTS) {
    if (signal.aborted) throw new UploadCancelled();
    breadcrumb('upload', 'attempt', { attempt, url: target.url });
    try {
      const res = await makeRequest(target, signal, onProgress, timeoutMs);
      return res;
    } catch (err) {
      lastErr = err;
      const kind = classify(err);
      breadcrumb('upload', 'attempt-failed', { attempt, kind, status: err.response?.status });
      if (kind === 'cancelled') throw new UploadCancelled();
      if (kind === 'fatal') {
        captureException(err, { attempt, url: target.url });
        throw Object.assign(new UploadFatal(err.message), { cause: err });
      }
      if (kind === 'expired') {
        target = await resolveTarget();
        // expired URL refresh does NOT burn a retry attempt
        continue;
      }
      if (attempt === MAX_ATTEMPTS) break;
      await sleep(jitter(BASE_BACKOFF_MS * 2 ** (attempt - 1)), signal);
      attempt++;
    }
  }
  captureException(lastErr, { exhausted: true });
  throw Object.assign(new UploadFatal('Upload failed after maximum retries'), { cause: lastErr });
}

/**
 * putWithRetry — presigned PUT for multipart parts.
 * resolveTarget: () => Promise<{ url, headers? }>
 */
export async function putWithRetry({ resolveTarget, body, onProgress, signal, timeoutMs = DEFAULT_TIMEOUT_MS }) {
  return withRetry({
    resolveTarget,
    signal,
    onProgress,
    timeoutMs,
    makeRequest: (target, sig, progressFn, timeout) =>
      _s3.request({
        method: 'PUT',
        url: target.url,
        data: body,
        headers: target.headers || {},
        timeout,
        signal: sig,
        onUploadProgress: e => {
          if (!e.total || !progressFn) return;
          progressFn(Math.round((e.loaded * 100) / e.total));
        },
      }),
  });
}

/**
 * postWithRetry — presigned POST for single-shot uploads.
 * resolveTarget: () => Promise<{ url, formData }>
 */
export async function postWithRetry({ resolveTarget, onProgress, signal, timeoutMs = DEFAULT_TIMEOUT_MS }) {
  return withRetry({
    resolveTarget,
    signal,
    onProgress,
    timeoutMs,
    makeRequest: (target, sig, progressFn, timeout) =>
      _s3.request({
        method: 'POST',
        url: target.url,
        data: target.formData,
        headers: {},
        timeout,
        signal: sig,
        onUploadProgress: e => {
          if (!e.total || !progressFn) return;
          progressFn(Math.round((e.loaded * 100) / e.total));
        },
      }),
  });
}
