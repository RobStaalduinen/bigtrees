// Global owner of all upload jobs. Promotes upload state out of Vue
// components so a job survives route navigation, and — backed by the
// persistence adapter — survives reload: on boot it hydrates persisted
// records and resumes any non-terminal work.
//
// The manager is plain JS (not reactive). Components subscribe() for the
// summary counts; a tiny Vuex/observable bridge (Chunk 9) turns those into
// reactive UI.

import { UploadJob, NON_TERMINAL, TERMINAL } from '../UploadJob.js';
import { createPersistence } from './persistence.js';

const DEFAULT_TTL_MS = 7 * 24 * 60 * 60 * 1000;       // 7 days
const DEFAULT_PURGE_INTERVAL_MS = 60 * 60 * 1000;     // hourly

function defaultIsOnline() {
  return typeof navigator === 'undefined' || navigator.onLine !== false;
}

export class UploadManager {
  constructor(options = {}) {
    this.jobs = new Map();
    this._subscribers = new Set();

    this.adapter   = options.adapter ?? null;
    this.JobClass  = options.JobClass ?? UploadJob;
    this.isOnline  = options.isOnline ?? defaultIsOnline;
    this.ttlMs     = options.ttlMs ?? DEFAULT_TTL_MS;
    this.purgeIntervalMs = options.purgeIntervalMs ?? DEFAULT_PURGE_INTERVAL_MS;
    // Web Locks guard around driving a job, so two tabs don't both drive the
    // same upload. Idempotency (client_upload_id) protects correctness even
    // where locks are unavailable.
    this._locks    = options.locks ?? (typeof navigator !== 'undefined' && navigator.locks ? navigator.locks : null);

    this._initialized = false;
  }

  // One-time boot: resolve the adapter, wire connectivity, hydrate.
  async init() {
    if (this._initialized) return this;
    this._initialized = true;
    this.adapter = this.adapter ?? await createPersistence();
    this._wireConnectivity();
    await this.hydrate();
    // Keep storage bounded over a long-lived session.
    if (typeof setInterval === 'function') {
      this._purgeTimer = setInterval(() => this._purge(), this.purgeIntervalMs);
    }
    return this;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  enqueue({ file, target = null, bucketName, presignPath, compress } = {}) {
    const job = new this.JobClass(file, {
      adapter:     this.adapter,
      target,
      bucketName,
      presignPath,
      compress,
      isOnline:    this.isOnline,
    });

    this.jobs.set(job.id, job);
    job.on(() => this._notify());
    // Persist the full record (incl. the blob) BEFORE the job starts patching
    // it — patch is a merge and no-ops on a missing record.
    job.ready = this._persistAndStart(job, file);
    this._notify();
    return job;
  }

  get(id) {
    return this.jobs.get(id) ?? null;
  }

  allJobs() {
    return [...this.jobs.values()];
  }

  jobsForTarget(predicate) {
    return [...this.jobs.values()].filter(job => predicate(job));
  }

  // The in-flight job (if any) for a (possibly pending) tree_image row, matched
  // by the client_upload_id the row carries. Only the browser that holds the
  // file blob has a matching job; everyone else gets null.
  jobFor(clientUploadId) {
    if (!clientUploadId) return null;
    return [...this.jobs.values()].find(j => j.clientUploadId === clientUploadId) ?? null;
  }

  // Optimistic local preview (objectURL) for such a row. Only the uploading
  // user gets their real image; everyone else falls through to the placeholder.
  previewFor(clientUploadId) {
    const job = this.jobFor(clientUploadId);
    return job && typeof job.localPreview === 'function' ? job.localPreview() : null;
  }

  // Rewire an unresolved (new-quote) job's target once the real tree exists,
  // persist it, and kick the job's association (placeholder creation + URL
  // fill — implemented on the job in Chunk 6).
  async resolveTarget(id, target) {
    const job = this.jobs.get(id);
    if (!job) return null;

    job.target = target;
    // Persist the target durably BEFORE returning, so a caller that navigates
    // (full page reload) right after can rely on hydrate resuming association.
    if (this.adapter) await this.adapter.patch(id, { target });
    // Kick the association (placeholder + URL-fill) but don't block on the
    // network — it continues in the background, and survives reload.
    if (typeof job.resolveTarget === 'function') job.resolveTarget(target);
    this._notify();
    return job;
  }

  retry(id) {
    const job = this.jobs.get(id);
    if (!job) return undefined;
    return this._drive(job);
  }

  async remove(id) {
    const job = this.jobs.get(id);
    if (job) {
      if (typeof job.abort === 'function') job.abort();
      if (typeof job.revokePreview === 'function') job.revokePreview();
      // Destroy any pending placeholder row so removal leaves nothing dangling.
      if (typeof job.deletePlaceholder === 'function') await job.deletePlaceholder();
    }
    this.jobs.delete(id);
    if (this.adapter) await this.adapter.delete(id);
    this._notify();
  }

  subscribe(fn) {
    this._subscribers.add(fn);
    fn(this.summary());
    return () => this._subscribers.delete(fn);
  }

  summary() {
    let active = 0;
    let failed = 0;
    for (const job of this.jobs.values()) {
      if (job.status === 'fatalError') failed++;
      else if (!TERMINAL.has(job.status)) active++;
    }
    return { active, failed, total: this.jobs.size };
  }

  // ---------------------------------------------------------------------------
  // Hydration / cleanup
  // ---------------------------------------------------------------------------

  async hydrate() {
    if (!this.adapter) return;

    await this._purge();

    const records = await this.adapter.all();
    for (const record of records) {
      const job = this._reconstruct(record);
      this.jobs.set(job.id, job);
      job.on(() => this._notify());
      if (NON_TERMINAL.has(job.status)) {
        this._drive(job);  // online-aware resume handled by the job
      }
    }
    this._notify();
  }

  // Drop finished records, then TTL-purge never-resolved/abandoned jobs. Run on
  // hydrate and periodically so storage stays bounded over a long session.
  async _purge() {
    if (!this.adapter) return;
    await this.adapter.purgeOlderThan(0, (r) => this._isFinished(r));
    await this.adapter.purgeOlderThan(this.ttlMs, (r) => this._isUnresolved(r));
  }

  // Clear everything — used on logout for privacy on shared devices. Aborts
  // in-flight jobs and empties the persisted store. Does NOT delete server-side
  // placeholder rows (those belong to the org's estimate, not this session).
  async clear() {
    if (this._purgeTimer) { clearInterval(this._purgeTimer); this._purgeTimer = null; }
    for (const job of this.jobs.values()) {
      if (typeof job.abort === 'function') job.abort();
      if (typeof job.revokePreview === 'function') job.revokePreview();
    }
    this.jobs.clear();
    if (this.adapter) {
      for (const record of await this.adapter.all()) {
        await this.adapter.delete(record.id);
      }
    }
    this._notify();
  }

  _isFinished(record) {
    return record.status === 'success' || record.status === 'done' || record.status === 'cancelled';
  }

  // A new-quote job whose target never resolved (or an abandoned one).
  _isUnresolved(record) {
    return !record.target || record.target.pending === true;
  }

  _reconstruct(record) {
    return new this.JobClass(record.blob, {
      id:             record.id,
      clientUploadId: record.clientUploadId,
      bucketName:     record.bucketName,
      presignPath:    record.presignPath,
      compress:       record.compress,
      target:         record.target,
      status:         record.status,
      progress:       record.progress,
      attempts:       record.attempts,
      multipart:      record.multipart,
      s3Url:          record.s3Url,
      placeholderId:  record.placeholderId,
      createdAt:      record.createdAt,
      updatedAt:      record.updatedAt,
      adapter:        this.adapter,
      isOnline:       this.isOnline,
    });
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  async _persistAndStart(job, file) {
    if (this.adapter) await this.adapter.put(this._record(job, file));
    await this._drive(job);
  }

  _record(job, file) {
    return {
      id:             job.id,
      clientUploadId: job.clientUploadId,
      blob:           file,
      filename:       file?.name,
      type:           file?.type,
      bucketName:     job.options.bucketName,
      presignPath:    job.options.presignPath,
      compress:       job.options.compress,
      status:         job.status,
      progress:       job.progress,
      s3Url:          job.s3Url,
      placeholderId:  job.placeholderId,
      multipart:      null,
      target:         job.target,
      attempts:       job.attempts,
      createdAt:      job.createdAt,
      updatedAt:      job.updatedAt,
    };
  }

  // Drive a job under a per-job Web Lock when available, so concurrent tabs
  // don't both run it. ifAvailable: a tab that doesn't get the lock simply
  // skips (the holding tab drives it; idempotency keeps it correct).
  _drive(job) {
    const run = () => (job.status === 'idle' ? job.start() : job.resume());

    if (this._locks && typeof this._locks.request === 'function') {
      return this._locks.request(`upload-job-${job.id}`, { ifAvailable: true }, (lock) => {
        if (!lock) return;
        return run();
      });
    }
    return run();
  }

  _wireConnectivity() {
    if (typeof window === 'undefined' || this._connectivityWired) return;
    this._connectivityWired = true;

    this._onOnline = () => {
      for (const job of this.jobs.values()) {
        if (job.status === 'retryableError') this._drive(job);
      }
    };
    this._onOffline = () => {
      for (const job of this.jobs.values()) {
        if (['compressing', 'preparing', 'uploading', 'finalizing'].includes(job.status)) {
          job.pause();
        }
      }
    };
    window.addEventListener('online', this._onOnline);
    window.addEventListener('offline', this._onOffline);
  }

  _notify() {
    const summary = this.summary();
    for (const fn of this._subscribers) fn(summary);
  }
}

// Process-wide singleton.
let _instance = null;

export function getUploadManager() {
  if (!_instance) _instance = new UploadManager();
  return _instance;
}

// Boot-time entry point (called once from the admin pack).
export function initUploadManager() {
  const manager = getUploadManager();
  manager.init().catch(() => { /* never block app boot on upload hydration */ });
  return manager;
}
