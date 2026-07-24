import { test } from 'node:test';
import assert from 'node:assert/strict';
import { UploadManager } from './uploadManager.js';
import { InMemoryPersistence } from './persistence.js';

// A minimal stand-in for UploadJob so manager orchestration is tested in
// isolation from real upload/network behaviour.
let counter = 0;
class FakeJob {
  constructor(file, options = {}) {
    this.file = file;
    this.options = {
      bucketName:  options.bucketName,
      presignPath: options.presignPath,
      compress:    options.compress
    };
    this.id             = options.id ?? `job-${++counter}`;
    this.clientUploadId = options.clientUploadId ?? `cuid-${this.id}`;
    this.target         = options.target ?? null;
    this.status         = options.status ?? 'idle';
    this.progress       = options.progress ?? 0;
    this.attempts       = options.attempts ?? 0;
    this.multipart      = options.multipart ?? null;
    this.createdAt      = options.createdAt ?? 1000;
    this.updatedAt      = options.updatedAt ?? 1000;
    this.adapter        = options.adapter ?? null;

    this.started = 0;
    this.resumed = 0;
    this.aborted = 0;
    this.placeholderDeleted = 0;
    this.placeholderId = options.placeholderId ?? null;
    this.s3Url = options.s3Url ?? null;
    this.resolvedTargets = [];
    this._listeners = new Set();
  }
  on(fn) { this._listeners.add(fn); return () => this._listeners.delete(fn); }
  start()  { this.started++; this.status = 'uploading'; return Promise.resolve(); }
  resume() { this.resumed++; return Promise.resolve(); }
  abort()  { this.aborted++; this.status = 'cancelled'; }
  pause()  { this.status = 'retryableError'; }
  resolveTarget(target) { this.resolvedTargets.push(target); return Promise.resolve(); }
  deletePlaceholder() { this.placeholderDeleted++; this.placeholderId = null; return Promise.resolve(); }
}

function manager(extra = {}) {
  return new UploadManager({ adapter: new InMemoryPersistence(), JobClass: FakeJob, ...extra });
}

function file(name = 'photo.jpg') {
  return new File(['data'], name, { type: 'image/jpeg' });
}

test('enqueue persists a full record (incl. blob + clientUploadId) and starts the job', async () => {
  const m = manager();
  const job = m.enqueue({ file: file(), target: { pending: true }, bucketName: 'tree_images', presignPath: '/tree_images/new', compress: true });
  await job.ready;

  assert.equal(m.get(job.id), job);
  assert.equal(job.started, 1);

  const records = await m.adapter.all();
  assert.equal(records.length, 1);
  const rec = records[0];
  assert.equal(rec.id, job.id);
  assert.equal(rec.clientUploadId, job.clientUploadId);
  assert.ok(rec.blob instanceof Blob);
  assert.equal(rec.bucketName, 'tree_images');
  assert.deepEqual(rec.target, { pending: true });
});

test('jobsForTarget filters by the predicate', async () => {
  const m = manager();
  const a = m.enqueue({ file: file('a.jpg'), target: { type: 'tree_image', tree_id: 1 } });
  const b = m.enqueue({ file: file('b.jpg'), target: { type: 'tree_image', tree_id: 2 } });
  await Promise.all([a.ready, b.ready]);

  const forTree2 = m.jobsForTarget(job => job.target?.tree_id === 2);
  assert.equal(forTree2.length, 1);
  assert.equal(forTree2[0].id, b.id);
});

test('resolveTarget rewires the target, persists it, and kicks the job association', async () => {
  const m = manager();
  const job = m.enqueue({ file: file(), target: { pending: true } });
  await job.ready;

  const resolved = { type: 'tree_image', estimate_id: 7, tree_id: 42 };
  await m.resolveTarget(job.id, resolved);

  assert.deepEqual(job.target, resolved);
  assert.deepEqual(job.resolvedTargets, [resolved], 'job association kicked');

  const rec = await m.adapter.get(job.id);
  assert.deepEqual(rec.target, resolved, 'target persisted');
});

test('remove aborts the job and deletes its record', async () => {
  const m = manager();
  const job = m.enqueue({ file: file() });
  await job.ready;

  await m.remove(job.id);

  assert.equal(job.aborted, 1);
  assert.equal(m.get(job.id), null);
  assert.equal(await m.adapter.get(job.id), null);
});

test('remove deletes the placeholder row when the job has one', async () => {
  const m = manager();
  const job = m.enqueue({ file: file(), target: { type: 'tree_image', estimate_id: 1, tree_id: 2 } });
  await job.ready;
  job.placeholderId = 'ti-9';

  await m.remove(job.id);

  assert.equal(job.aborted, 1);
  assert.equal(job.placeholderDeleted, 1, 'placeholder DELETE issued');
  assert.equal(m.get(job.id), null);
});

test('summary counts active vs failed', async () => {
  const m = manager();
  const a = m.enqueue({ file: file('a.jpg') });
  const b = m.enqueue({ file: file('b.jpg') });
  await Promise.all([a.ready, b.ready]);
  b.status = 'fatalError';

  assert.deepEqual(m.summary(), { active: 1, failed: 1, total: 2 });
});

test('subscribe is called immediately and on changes', async () => {
  const m = manager();
  const seen = [];
  const unsub = m.subscribe(s => seen.push(s));
  assert.deepEqual(seen[0], { active: 0, failed: 0, total: 0 });

  const job = m.enqueue({ file: file() });
  await job.ready;
  assert.ok(seen.length >= 2);
  assert.equal(seen[seen.length - 1].total, 1);

  unsub();
});

test('hydrate resumes non-terminal jobs, purges finished, and TTL-purges abandoned', async () => {
  const adapter = new InMemoryPersistence();
  const old = Date.now() - (8 * 24 * 60 * 60 * 1000);  // older than the 7-day TTL

  // A non-terminal, target-resolved job that should resume.
  await adapter.put({
    id: 'live', clientUploadId: 'c-live', blob: file(), status: 'uploading',
    target: { type: 'tree_image', tree_id: 1 }, attempts: 2, updatedAt: Date.now()
  });
  // A finished job — purged on hydrate regardless of age.
  await adapter.put({
    id: 'done', clientUploadId: 'c-done', blob: file(), status: 'success',
    target: { type: 'tree_image', tree_id: 2 }, updatedAt: Date.now()
  });
  // An abandoned (never-resolved) new-quote job, older than TTL — purged.
  await adapter.put({
    id: 'abandoned', clientUploadId: 'c-ab', blob: file(), status: 'awaitingTarget',
    target: { pending: true }, updatedAt: old
  });
  // A fresh unresolved job — kept (within TTL).
  await adapter.put({
    id: 'fresh-pending', clientUploadId: 'c-fresh', blob: file(), status: 'uploading',
    target: { pending: true }, updatedAt: Date.now()
  });

  const m = new UploadManager({ adapter, JobClass: FakeJob, isOnline: () => true });
  await m.hydrate();

  // 'done' and 'abandoned' purged from storage.
  assert.equal(await adapter.get('done'), null, 'finished record purged');
  assert.equal(await adapter.get('abandoned'), null, 'TTL-expired abandoned record purged');

  // Live + fresh-pending reconstructed.
  assert.ok(m.get('live'));
  assert.ok(m.get('fresh-pending'));
  assert.equal(m.get('done'), null);

  // Non-terminal reconstructed jobs were resumed (status !== idle → resume()).
  assert.equal(m.get('live').resumed, 1);
  assert.equal(m.get('fresh-pending').resumed, 1);
});

test('allJobs returns every tracked job', async () => {
  const m = manager();
  const a = m.enqueue({ file: file('a.jpg') });
  const b = m.enqueue({ file: file('b.jpg') });
  await Promise.all([a.ready, b.ready]);

  const ids = m.allJobs().map(j => j.id).sort();
  assert.deepEqual(ids, [a.id, b.id].sort());
});

test('clear aborts all jobs and empties the persisted store', async () => {
  const m = manager();
  const a = m.enqueue({ file: file('a.jpg') });
  const b = m.enqueue({ file: file('b.jpg'), target: { type: 'tree_image', estimate_id: 1, tree_id: 2 } });
  await Promise.all([a.ready, b.ready]);

  await m.clear();

  assert.equal(a.aborted, 1);
  assert.equal(b.aborted, 1);
  assert.equal(m.allJobs().length, 0);
  assert.equal((await m.adapter.all()).length, 0, 'persisted store emptied');
});

test('_purge drops finished and TTL-expired records (re-runnable)', async () => {
  const adapter = new InMemoryPersistence();
  const old = Date.now() - (8 * 24 * 60 * 60 * 1000);
  await adapter.put({ id: 'done', blob: file(), status: 'success', target: { tree_id: 1 }, updatedAt: Date.now() });
  await adapter.put({ id: 'abandoned', blob: file(), status: 'uploading', target: { pending: true }, updatedAt: old });
  await adapter.put({ id: 'live', blob: file(), status: 'uploading', target: { tree_id: 2 }, updatedAt: Date.now() });

  const m = new UploadManager({ adapter, JobClass: FakeJob });
  await m._purge();

  assert.equal(await adapter.get('done'), null);
  assert.equal(await adapter.get('abandoned'), null);
  assert.ok(await adapter.get('live'));
});

test('_drive uses the Web Locks API when available', async () => {
  const requests = [];
  const fakeLocks = {
    request: async (name, opts, cb) => {
      requests.push({ name, opts });
      return cb({ name });  // grant the lock
    }
  };
  const m = manager({ locks: fakeLocks });

  const job = m.enqueue({ file: file() });
  await job.ready;

  assert.ok(requests.length >= 1);
  assert.equal(requests[0].name, `upload-job-${job.id}`);
  assert.equal(requests[0].opts.ifAvailable, true);
  assert.equal(job.started, 1);
});

test('_drive skips running when the lock is not granted', async () => {
  const fakeLocks = {
    request: async (name, opts, cb) => cb(null)  // lock unavailable
  };
  const m = manager({ locks: fakeLocks });

  const job = m.enqueue({ file: file() });
  await job.ready;

  assert.equal(job.started, 0, 'did not run without the lock');
});
