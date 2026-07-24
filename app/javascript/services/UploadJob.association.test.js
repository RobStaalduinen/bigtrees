import { test } from 'node:test';
import assert from 'node:assert/strict';
import { UploadJob } from './UploadJob.js';

const RESOLVED = { type: 'tree_image', estimate_id: 5, tree_id: 9 };

function textFile() {
  return new File(['hello'], 'photo.jpg', { type: 'image/jpeg' });
}

// Drain pending micro/macrotasks so background association work settles.
async function flush() {
  for (let i = 0; i < 12; i++) await new Promise(r => setTimeout(r, 0));
}

function deferred() {
  let resolve, reject;
  const promise = new Promise((res, rej) => { resolve = res; reject = rej; });
  return { promise, resolve, reject };
}

// setTimeoutFn that fires immediately, so internal retry backoff doesn't stall.
const immediate = (fn) => { fn(); return 1; };

function baseClient(overrides = {}) {
  return {
    railsGet: async () => ({ data: { url: 's3', fields: {} } }),
    signedUrlFormData: async () => ({}),
    parseImageUploadResponse: async () => 'https://s3/photo.jpg',
    postWithRetry: async () => ({}),
    ...overrides
  };
}

test('resolved target: placeholder is created before S3, URL filled after → done', async () => {
  const s3 = deferred();
  const calls = [];
  const client = baseClient({
    postWithRetry: async () => s3.promise,
    associate: async (p) => { calls.push(p); return { id: 'ti-1', ready: p.image_url != null }; }
  });

  const job = new UploadJob(textFile(), { compress: false, client, target: RESOLVED, setTimeoutFn: immediate });
  const started = job.start();

  await flush();
  // Placeholder created while S3 is still in flight.
  assert.equal(calls.length, 1, 'one associate (placeholder) before S3 completes');
  assert.equal(calls[0].image_url, undefined, 'placeholder call has no image_url');
  assert.equal(job.placeholderId, 'ti-1');
  // S3 still in flight, so the job is still 'uploading'; association is orthogonal.
  assert.equal(job.status, 'uploading');

  s3.resolve({});
  await started;

  assert.equal(job.status, 'done');
  assert.equal(calls.length, 2, 'second associate fills the URL');
  assert.equal(calls[1].image_url, 'https://s3/photo.jpg');
  assert.equal(job.url, 'https://s3/photo.jpg');
});

test('order-independent: S3 first, placeholder later — converges to one done, two calls, one client_upload_id', async () => {
  const placeholderGate = deferred();
  const calls = [];
  const client = baseClient({
    postWithRetry: async () => ({}),                 // S3 finishes immediately
    associate: async (p) => {
      calls.push(p);
      if (p.image_url == null) await placeholderGate.promise;  // delay the placeholder
      return { id: 'ti-1', ready: p.image_url != null };
    }
  });

  const job = new UploadJob(textFile(), { compress: false, client, target: RESOLVED, setTimeoutFn: immediate });
  const started = job.start();

  await flush();
  assert.equal(job.s3Url, 'https://s3/photo.jpg', 'S3 done first');
  assert.equal(job.placeholderId, null, 'placeholder still in flight');
  assert.equal(job.status, 'pendingAssociation');

  placeholderGate.resolve();
  await started;

  assert.equal(job.status, 'done');
  assert.equal(calls.length, 2);
  assert.ok(calls.some(c => c.image_url == null) && calls.some(c => c.image_url === 'https://s3/photo.jpg'));
  assert.ok(calls.every(c => c.client_upload_id === job.clientUploadId), 'same idempotency key');
});

test('retryable failure on the placeholder track retries to success', async () => {
  let placeholderAttempts = 0;
  const client = baseClient({
    associate: async (p) => {
      if (p.image_url == null) {
        placeholderAttempts++;
        if (placeholderAttempts < 3) throw new Error('network flake');  // no response → retryable
      }
      return { id: 'ti-1', ready: p.image_url != null };
    }
  });

  const job = new UploadJob(textFile(), { compress: false, client, target: RESOLVED, setTimeoutFn: immediate, random: () => 0.5 });
  await job.start();

  assert.equal(job.status, 'done');
  assert.ok(placeholderAttempts >= 3, 'retried the placeholder until it succeeded');
});

test('retryable failure on the URL-fill track retries to success', async () => {
  let fillAttempts = 0;
  const client = baseClient({
    associate: async (p) => {
      if (p.image_url != null) {
        fillAttempts++;
        if (fillAttempts < 3) throw new Error('network flake');
      }
      return { id: 'ti-1', ready: p.image_url != null };
    }
  });

  const job = new UploadJob(textFile(), { compress: false, client, target: RESOLVED, setTimeoutFn: immediate, random: () => 0.5 });
  await job.start();

  assert.equal(job.status, 'done');
  assert.ok(fillAttempts >= 3);
});

test('unresolved target: no placeholder until resolveTarget; sits in awaitingTarget, then done', async () => {
  const calls = [];
  const client = baseClient({
    associate: async (p) => { calls.push(p); return { id: 'ti-1', ready: p.image_url != null }; }
  });

  const job = new UploadJob(textFile(), { compress: false, client, target: { type: 'tree_image', pending: true }, setTimeoutFn: immediate });
  await job.start();

  assert.equal(job.status, 'awaitingTarget', 'S3 done but target unresolved');
  assert.equal(calls.length, 0, 'no association attempted before resolveTarget');

  await job.resolveTarget(RESOLVED);

  assert.equal(job.status, 'done');
  assert.equal(calls.length, 2, 'placeholder then URL-fill');
  assert.equal(job.url, 'https://s3/photo.jpg');
});

test('a fatal association error stops at fatalError', async () => {
  const client = baseClient({
    associate: async () => {
      const err = new Error('validation failed');
      err.response = { status: 422, data: 'invalid' };
      throw err;
    }
  });

  const job = new UploadJob(textFile(), { compress: false, client, target: RESOLVED, setTimeoutFn: immediate });
  await job.start();

  assert.equal(job.status, 'fatalError');
  assert.equal(job.error.retryable, false);
});

test('deletePlaceholder issues a DELETE and clears placeholderId', async () => {
  let deleted = null;
  const client = baseClient({
    deleteTreeImage: async (id, estimateId) => { deleted = { id, estimateId }; }
  });

  const job = new UploadJob(textFile(), { compress: false, client, target: RESOLVED });
  job.placeholderId = 'ti-7';

  await job.deletePlaceholder();

  assert.deepEqual(deleted, { id: 'ti-7', estimateId: 5 });
  assert.equal(job.placeholderId, null);
});

test('a targetless (generic) upload still finishes at success, never associates', async () => {
  let associateCalled = false;
  const client = baseClient({ associate: async () => { associateCalled = true; return { id: 'x' }; } });

  const job = new UploadJob(textFile(), { compress: false, client });  // no target
  await job.start();

  assert.equal(job.status, 'success');
  assert.equal(job.url, 'https://s3/photo.jpg');
  assert.equal(associateCalled, false);
});
