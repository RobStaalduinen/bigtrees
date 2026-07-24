import { test } from 'node:test';
import assert from 'node:assert/strict';
import { UploadJob } from './UploadJob.js';
import { UploadFatal, UploadCancelled } from './uploadClient.js';

function textFile() {
  return new File(['hello'], 'note.txt', { type: 'text/plain' });
}

const tick = () => new Promise(r => setTimeout(r, 0));

// An upload that hangs until its signal aborts, then rejects exactly like the
// real S3 client does on a cancel.
function hangUntilAbort(signal) {
  return new Promise((_, reject) => {
    signal.addEventListener('abort', () => reject(new UploadCancelled()), { once: true });
  });
}

function makeAdapter() {
  const patches = [];
  return {
    patches,
    patch: (id, partial) => { patches.push(partial); return Promise.resolve(partial); }
  };
}

// Regression for the offline-during-upload bug: pause()'s abort must not be
// mistaken for a user cancel, or the job dies in 'cancelled' and never resumes.
test('pause() during an in-flight upload lands in retryableError and resumes (not cancelled)', async () => {
  let attempts = 0;
  const client = {
    railsGet: async () => ({ data: { url: 's3', fields: {} } }),
    signedUrlFormData: async () => ({}),
    parseImageUploadResponse: async () => 'https://s3/photo.jpg',
    postWithRetry: ({ signal }) => {
      attempts++;
      return attempts === 1 ? hangUntilAbort(signal) : Promise.resolve({});
    }
  };

  const job = new UploadJob(textFile(), { compress: false, client, isOnline: () => true });
  const started = job.start();
  await tick();
  assert.equal(job.status, 'uploading');

  job.pause();                 // simulates manager's offline handler
  await started;
  assert.equal(job.status, 'retryableError', 'pause must NOT cancel the job');

  await job.resume();          // simulates reconnect
  assert.equal(job.status, 'success', 'resumes and completes after reconnect');
});

test('abort() is a genuine cancel and lands in cancelled', async () => {
  const client = {
    railsGet: async () => ({ data: { url: 's3', fields: {} } }),
    signedUrlFormData: async () => ({}),
    postWithRetry: ({ signal }) => hangUntilAbort(signal)
  };

  const job = new UploadJob(textFile(), { compress: false, client, isOnline: () => true });
  const started = job.start();
  await tick();

  job.abort();
  await started;
  assert.equal(job.status, 'cancelled');
});

test('a constructor-supplied clientUploadId is reused (stable across resume)', () => {
  const job = new UploadJob(textFile(), { clientUploadId: 'fixed-uuid' });
  assert.equal(job.clientUploadId, 'fixed-uuid');
});

test('single-shot success reaches success and writes through every transition', async () => {
  const adapter = makeAdapter();
  const client = {
    railsGet: async () => ({ data: { url: 's3', fields: {} } }),
    signedUrlFormData: async () => ({}),
    postWithRetry: async ({ onProgress }) => { onProgress?.(100); return { ok: true }; },
    parseImageUploadResponse: async () => 'https://s3/photo.jpg'
  };

  const job = new UploadJob(textFile(), { compress: false, adapter, client });
  await job.start();

  assert.equal(job.status, 'success');
  assert.equal(job.url, 'https://s3/photo.jpg');
  assert.equal(job.progress, 100);

  const statuses = adapter.patches.map(p => p.status).filter(Boolean);
  assert.ok(statuses.includes('preparing'), 'persisted preparing');
  assert.ok(statuses.includes('uploading'), 'persisted uploading');
  assert.ok(statuses.includes('success'), 'persisted success');
  // every persisted transition carries the idempotency-relevant fields
  assert.ok(adapter.patches.every(p => 'progress' in p));
});

test('retryable errors retry indefinitely with capped, growing backoff and never go fatal', async () => {
  const delays = [];
  let scheduled = null;
  const client = {
    railsGet: async () => ({ data: { url: 's3', fields: {} } }),
    signedUrlFormData: async () => ({}),
    postWithRetry: async () => { throw new Error('network flake'); }
  };

  const job = new UploadJob(textFile(), {
    compress: false,
    client,
    random: () => 0.5,           // jitter → exact exponential
    isOnline: () => true,
    setTimeoutFn: (fn, ms) => { delays.push(ms); scheduled = fn; return delays.length; },
    clearTimeoutFn: () => {}
  });

  await job.start();
  for (let i = 0; i < 9 && scheduled; i++) {
    const fn = scheduled;
    scheduled = null;
    await fn();   // fire the scheduled retry; it fails and reschedules
  }

  assert.equal(job.status, 'retryableError');
  assert.notEqual(job.status, 'fatalError');
  assert.ok(job.attempts >= 8, `attempts grew (${job.attempts})`);
  assert.deepEqual(delays.slice(0, 7), [1000, 2000, 4000, 8000, 16000, 32000, 60000]);
  assert.equal(delays[7], 60000, 'capped at 60s');
});

test('an offline retryable error does not schedule a tight-loop timer', async () => {
  const delays = [];
  const client = {
    railsGet: async () => ({ data: { url: 's3', fields: {} } }),
    signedUrlFormData: async () => ({}),
    postWithRetry: async () => { throw new Error('offline'); }
  };

  const job = new UploadJob(textFile(), {
    compress: false,
    client,
    isOnline: () => false,
    setTimeoutFn: (fn, ms) => { delays.push(ms); return 1; },
    clearTimeoutFn: () => {}
  });

  await job.start();
  assert.equal(job.status, 'retryableError');
  assert.equal(delays.length, 0, 'no retry scheduled while offline');
});

test('UploadFatal goes straight to fatalError and schedules no retry', async () => {
  const delays = [];
  const client = {
    railsGet: async () => ({ data: { url: 's3', fields: {} } }),
    signedUrlFormData: async () => ({}),
    postWithRetry: async () => { throw new UploadFatal('forbidden'); }
  };

  const job = new UploadJob(textFile(), {
    compress: false,
    client,
    setTimeoutFn: (fn, ms) => { delays.push(ms); return 1; },
    clearTimeoutFn: () => {}
  });

  await job.start();
  assert.equal(job.status, 'fatalError');
  assert.equal(job.error.retryable, false);
  assert.equal(delays.length, 0);
});

test('an expired multipart on resume resets state and restarts fresh', async () => {
  let completeCalls = 0;
  const client = {
    railsGet: async () => ({ data: { url: 's3', fields: {} } }),
    signedUrlFormData: async () => ({}),
    parseImageUploadResponse: async () => 'https://s3/final.jpg',
    postWithRetry: async () => ({}),                  // fresh single-shot succeeds
    railsPost: async (path) => {
      if (path.includes('/complete')) {
        completeCalls++;
        const err = new Error('NoSuchUpload: The specified upload does not exist');
        err.response = { status: 404 };
        throw err;
      }
      return { data: {} };
    }
  };

  const job = new UploadJob(textFile(), { compress: false, client });
  // Simulate a hydrated, stale multipart whose parts are all "done".
  job._uploadId = 'stale-upload';
  job._key = 'tree_images/x';
  job._parts = [{ partNumber: 1, status: 'done', etag: 'e1', blob: null }];
  job._compressedBlob = job.file;
  job.status = 'retryableError';

  await job.retry();

  assert.equal(job.status, 'success');
  assert.equal(job.url, 'https://s3/final.jpg');
  assert.equal(job._uploadId, null, 'stale multipart cleared');
  assert.ok(completeCalls >= 1, 'attempted the stale complete before restarting');
});
