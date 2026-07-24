// Durable storage layer for the background upload queue.
//
// Exposes one async interface — all/get/put/patch/delete/purgeOlderThan —
// backed by IndexedDB when available, and transparently degrading to a
// non-durable in-memory Map when IndexedDB is missing or throws (private
// mode, some embedded webviews). Uploads must keep working either way; the
// only thing lost in the fallback is survival across reload.
//
// A persisted record is shaped like:
//   { id, clientUploadId, blob, filename, type, bucketName, presignPath,
//     compress, status, progress, multipart, target, attempts,
//     createdAt, updatedAt }
// but this layer is schema-agnostic: it stores whatever it is given, only
// defaulting createdAt/updatedAt when absent.

const DB_NAME = 'bigtrees_uploads';
const DB_VERSION = 1;
const STORE = 'upload_jobs';

function now() {
  return Date.now();
}

// Fill in timestamps only when the caller didn't supply them, so a record's
// own updatedAt (set by the job on each state transition) is preserved.
function ensureTimestamps(record) {
  const ts = now();
  return {
    ...record,
    createdAt: record.createdAt ?? ts,
    updatedAt: record.updatedAt ?? ts
  };
}

// Non-durable fallback. Same interface as the IndexedDB adapter.
export class InMemoryPersistence {
  constructor() {
    this._map = new Map();
    this.durable = false;
  }

  async all() {
    return [...this._map.values()];
  }

  async get(id) {
    return this._map.get(id) ?? null;
  }

  async put(record) {
    const stored = ensureTimestamps(record);
    this._map.set(stored.id, stored);
    return stored;
  }

  async patch(id, partial) {
    const existing = this._map.get(id);
    if (!existing) return null;

    const merged = { ...existing, ...partial, updatedAt: partial.updatedAt ?? now() };
    this._map.set(id, merged);
    return merged;
  }

  async delete(id) {
    this._map.delete(id);
  }

  // Remove records whose updatedAt is older than `ms` ago AND that match the
  // predicate. Returns the ids removed.
  async purgeOlderThan(ms, predicate = () => true) {
    const cutoff = now() - ms;
    const removed = [];
    for (const record of [...this._map.values()]) {
      if (record.updatedAt <= cutoff && predicate(record)) {
        this._map.delete(record.id);
        removed.push(record.id);
      }
    }
    return removed;
  }
}

function promisifyRequest(request) {
  return new Promise((resolve, reject) => {
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

// IndexedDB-backed adapter. One object store keyed by `id`.
export class IndexedDbPersistence {
  constructor(db) {
    this._db = db;
    this.durable = true;
  }

  _store(mode) {
    return this._db.transaction(STORE, mode).objectStore(STORE);
  }

  async all() {
    return (await promisifyRequest(this._store('readonly').getAll())) ?? [];
  }

  async get(id) {
    return (await promisifyRequest(this._store('readonly').get(id))) ?? null;
  }

  async put(record) {
    const stored = ensureTimestamps(record);
    await promisifyRequest(this._store('readwrite').put(stored));
    return stored;
  }

  async patch(id, partial) {
    const existing = await this.get(id);
    if (!existing) return null;

    const merged = { ...existing, ...partial, updatedAt: partial.updatedAt ?? now() };
    await promisifyRequest(this._store('readwrite').put(merged));
    return merged;
  }

  async delete(id) {
    await promisifyRequest(this._store('readwrite').delete(id));
  }

  async purgeOlderThan(ms, predicate = () => true) {
    const cutoff = now() - ms;
    const removed = [];
    for (const record of await this.all()) {
      if (record.updatedAt <= cutoff && predicate(record)) {
        await this.delete(record.id);
        removed.push(record.id);
      }
    }
    return removed;
  }
}

function openIndexedDb() {
  return new Promise((resolve, reject) => {
    if (typeof indexedDB === 'undefined' || indexedDB === null) {
      reject(new Error('IndexedDB unavailable'));
      return;
    }

    let request;
    try {
      request = indexedDB.open(DB_NAME, DB_VERSION);
    } catch (e) {
      // Some contexts throw synchronously on open (e.g. private mode).
      reject(e);
      return;
    }

    request.onupgradeneeded = () => {
      const db = request.result;
      if (!db.objectStoreNames.contains(STORE)) {
        db.createObjectStore(STORE, { keyPath: 'id' });
      }
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error || new Error('IndexedDB open failed'));
    request.onblocked = () => reject(new Error('IndexedDB open blocked'));
  });
}

// Best-effort request for storage that won't be evicted under pressure. iOS
// may ignore this for non-installed web apps; never relied upon.
function requestPersistentStorage() {
  try {
    if (typeof navigator !== 'undefined' && navigator.storage && navigator.storage.persist) {
      navigator.storage.persist().catch(() => {});
    }
  } catch (e) {
    // best-effort only
  }
}

// Returns the best available persistence adapter, degrading to in-memory
// rather than throwing so the app never crashes on a missing/blocked store.
export async function createPersistence() {
  requestPersistentStorage();
  try {
    const db = await openIndexedDb();
    return new IndexedDbPersistence(db);
  } catch (e) {
    return new InMemoryPersistence();
  }
}
