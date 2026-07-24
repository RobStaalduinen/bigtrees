import { test } from 'node:test';
import assert from 'node:assert/strict';
import { InMemoryPersistence, IndexedDbPersistence, createPersistence } from './persistence.js';

function sampleRecord(overrides = {}) {
  return {
    id: 'job-1',
    clientUploadId: 'uuid-1',
    blob: new Blob(['hello world'], { type: 'text/plain' }),
    filename: 'photo.jpg',
    type: 'tree_image',
    bucketName: 'bigtrees',
    presignPath: '/tree_images/new',
    compress: true,
    status: 'uploading',
    progress: 0,
    multipart: null,
    target: { type: 'tree_image', pending: true },
    attempts: 0,
    ...overrides
  };
}

test('InMemoryPersistence round-trips a record including a Blob', async () => {
  const store = new InMemoryPersistence();
  const record = sampleRecord();

  await store.put(record);
  const got = await store.get('job-1');

  assert.equal(got.id, 'job-1');
  assert.equal(got.clientUploadId, 'uuid-1');
  assert.ok(got.blob instanceof Blob);
  assert.equal(await got.blob.text(), 'hello world');
  assert.ok(got.createdAt, 'createdAt defaulted');
  assert.ok(got.updatedAt, 'updatedAt defaulted');

  const all = await store.all();
  assert.equal(all.length, 1);
});

test('put preserves a caller-supplied updatedAt', async () => {
  const store = new InMemoryPersistence();
  await store.put(sampleRecord({ updatedAt: 12345 }));
  const got = await store.get('job-1');
  assert.equal(got.updatedAt, 12345);
});

test('patch merges into the existing record and bumps updatedAt', async () => {
  const store = new InMemoryPersistence();
  await store.put(sampleRecord({ updatedAt: 1 }));

  const merged = await store.patch('job-1', { status: 'done', progress: 100 });

  assert.equal(merged.status, 'done');
  assert.equal(merged.progress, 100);
  assert.equal(merged.clientUploadId, 'uuid-1', 'untouched fields survive');
  assert.ok(merged.updatedAt > 1, 'updatedAt bumped');

  const got = await store.get('job-1');
  assert.equal(got.status, 'done');
});

test('patch returns null for an unknown id and creates nothing', async () => {
  const store = new InMemoryPersistence();
  const result = await store.patch('nope', { status: 'done' });
  assert.equal(result, null);
  assert.equal((await store.all()).length, 0);
});

test('delete removes a record', async () => {
  const store = new InMemoryPersistence();
  await store.put(sampleRecord());
  await store.delete('job-1');
  assert.equal(await store.get('job-1'), null);
});

test('purgeOlderThan removes only old records matching the predicate', async () => {
  const store = new InMemoryPersistence();
  const old = Date.now() - 10_000;
  const fresh = Date.now();

  await store.put(sampleRecord({ id: 'old-match', updatedAt: old, status: 'awaitingTarget' }));
  await store.put(sampleRecord({ id: 'old-nomatch', updatedAt: old, status: 'done' }));
  await store.put(sampleRecord({ id: 'fresh-match', updatedAt: fresh, status: 'awaitingTarget' }));

  const removed = await store.purgeOlderThan(1_000, (r) => r.status === 'awaitingTarget');

  assert.deepEqual(removed, ['old-match']);
  assert.equal(await store.get('old-match'), null);
  assert.ok(await store.get('old-nomatch'), 'wrong-status record kept');
  assert.ok(await store.get('fresh-match'), 'fresh record kept');
});

test('purgeOlderThan defaults to purging all old records', async () => {
  const store = new InMemoryPersistence();
  await store.put(sampleRecord({ id: 'a', updatedAt: Date.now() - 10_000 }));
  await store.put(sampleRecord({ id: 'b', updatedAt: Date.now() }));

  const removed = await store.purgeOlderThan(1_000);
  assert.deepEqual(removed, ['a']);
});

test('createPersistence falls back to in-memory when indexedDB is undefined', async () => {
  const saved = globalThis.indexedDB;
  delete globalThis.indexedDB;
  try {
    const store = await createPersistence();
    assert.equal(store.durable, false, 'in-memory fallback is non-durable');

    // Still satisfies the full interface.
    await store.put(sampleRecord());
    assert.equal((await store.get('job-1')).id, 'job-1');
    await store.patch('job-1', { status: 'done' });
    assert.equal((await store.get('job-1')).status, 'done');
    await store.delete('job-1');
    assert.equal(await store.get('job-1'), null);
  } finally {
    if (saved !== undefined) globalThis.indexedDB = saved;
  }
});

test('createPersistence falls back to in-memory when indexedDB.open throws', async () => {
  const saved = globalThis.indexedDB;
  globalThis.indexedDB = {
    open() {
      throw new Error('SecurityError: private mode');
    }
  };
  try {
    const store = await createPersistence();
    assert.equal(store.durable, false);
    await store.put(sampleRecord());
    assert.equal((await store.all()).length, 1);
  } finally {
    if (saved === undefined) delete globalThis.indexedDB;
    else globalThis.indexedDB = saved;
  }
});

// Sanity: both adapters expose the same method surface.
test('IndexedDbPersistence exposes the same interface as InMemoryPersistence', () => {
  const methods = ['all', 'get', 'put', 'patch', 'delete', 'purgeOlderThan'];
  for (const m of methods) {
    assert.equal(typeof IndexedDbPersistence.prototype[m], 'function', `missing ${m}`);
    assert.equal(typeof InMemoryPersistence.prototype[m], 'function', `missing ${m}`);
  }
});
