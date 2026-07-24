<template>
  <div class="app-uploader">
    <!-- Compact: a plain clickable link backed by a hidden native input, for
         vertically tight contexts. Otherwise the standard b-form-file box. -->
    <template v-if="compact">
      <a class="app-uploader__trigger" @click.prevent="openPicker">{{ triggerText }} +</a>
      <input
        ref="fileInput"
        type="file"
        class="app-uploader__hidden-input"
        :name="name"
        :multiple="multiple"
        :accept="accept"
        @change="onInputChange"
      />
    </template>
    <b-form-file
      v-else
      :id="id"
      :name="name"
      :multiple="multiple"
      :accept="accept"
      :placeholder="placeholder"
      :value="null"
      class="text-nowrap text-truncate"
      @input="onFilesSelected"
    ></b-form-file>

    <div v-if="items.length" class="app-uploader__grid">
      <div
        v-for="item in items"
        :key="item.id"
        class="app-uploader__item"
        :class="{ 'app-uploader__item--error': item.isError }"
      >
        <img v-if="item.preview" :src="item.preview" class="app-uploader__thumb" :alt="item.id" />
        <div v-else class="app-uploader__thumb app-uploader__thumb--empty">
          <b-icon icon="image"></b-icon>
        </div>

        <!-- In-flight veil: optimistic thumb stays visible underneath. -->
        <div v-if="item.inProgress" class="app-uploader__veil">
          <b-spinner small class="app-uploader__spinner"></b-spinner>
          <span v-if="item.progress" class="app-uploader__pct">{{ item.progress }}%</span>
        </div>

        <div v-if="item.isError" class="app-uploader__veil app-uploader__veil--error">
          <b-icon icon="exclamation-triangle" class="app-uploader__error-icon"></b-icon>
        </div>

        <div class="app-uploader__actions">
          <b-icon
            v-if="item.isRetryable"
            icon="arrow-clockwise"
            class="app-uploader__action"
            title="Retry"
            @click="retry(item.id)"
          ></b-icon>
          <b-icon
            icon="x-circle-fill"
            class="app-uploader__action"
            title="Remove"
            @click="remove(item.id)"
          ></b-icon>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// Flexible, manager-backed uploader. Accepts files instantly, shows an
// optimistic local preview, and hands the file to the durable global queue —
// which drives the S3 upload AND (for tree_image targets) the DB association
// in the background. The component owns no upload state: it renders a view of
// the manager's jobs for the ids it created, so it survives unmount/remount
// (the parent's v-model retains the job list).

// The spinner/veil reflects whether the S3 *transfer* is still in flight.
// Once the bytes are in S3 the thumbnail is shown as complete, even if the
// background DB association is still pending (new-quote 'awaitingTarget' waits
// for form submit; 'pendingAssociation' is a brief background step).
const S3_IN_FLIGHT = new Set(['idle', 'compressing', 'preparing', 'uploading', 'finalizing', 'retryableError']);

export default {
  props: {
    // Association descriptor: a resolved { type:'tree_image', estimate_id, tree_id }
    // or an unresolved { type:'tree_image', pending:true }, or null for a
    // generic upload that needs no association.
    target:      { required: false, default: null },
    multiple:    { type: Boolean, default: true },
    accept:      { type: String,  required: false },
    bucketName:  { type: String,  default: 'tree_images' },
    presignPath: { type: String,  default: '/tree_images/new' },
    compress:    { type: Boolean, default: true },
    placeholder: { type: String,  default: 'Choose images…' },
    // Compact mode: render a clickable link instead of the large file box.
    compact:     { type: Boolean, default: false },
    triggerText: { type: String,  default: 'Choose images' },
    id:          { type: String,  required: false },
    name:        { type: String,  default: 'image' },
    value:       { required: false, default: () => [] }
  },
  data() {
    return {
      jobIds: (this.value || []).map(v => v.id),
      items: []
    };
  },
  methods: {
    openPicker() {
      if (this.$refs.fileInput) this.$refs.fileInput.click();
    },

    onInputChange(event) {
      const files = event.target.files ? Array.from(event.target.files) : [];
      this.onFilesSelected(files);
      // Clear so re-picking the same file still fires change.
      event.target.value = '';
    },

    onFilesSelected(files) {
      if (!files) return;
      const list = Array.isArray(files) ? files : [files];
      for (const file of list) {
        if (!file) continue;
        const job = this.$uploads.enqueue({
          file,
          target:      this.target,
          bucketName:  this.bucketName,
          presignPath: this.presignPath,
          compress:    this.compress
        });
        this.jobIds.push(job.id);
      }
      this.refresh();
    },

    retry(id) {
      this.$uploads.retry(id);
      this.refresh();
    },

    remove(id) {
      // The manager owns the preview objectURL's lifetime and revokes it here.
      this.$uploads.remove(id);
      this.jobIds = this.jobIds.filter(jid => jid !== id);
      this.refresh();
    },

    // Rebuild the reactive view from the manager (which is plain JS) and emit.
    refresh() {
      this.items = this.jobIds
        .map(id => this._viewOf(id))
        // A cancelled/removed job is gone — never show it as an eternal spinner.
        .filter(view => view && view.status !== 'cancelled');

      this.$emit('input', this.items.map(i => ({
        id:             i.id,
        clientUploadId: i.clientUploadId,
        status:         i.status,
        url:            i.url
      })));
      this.$emit('summary', this.summary());
    },

    _viewOf(id) {
      const job = this.$uploads.get(id);
      if (!job) return null;
      const isError = job.status === 'fatalError';
      const inProgress = S3_IN_FLIGHT.has(job.status);
      return {
        id:             job.id,
        clientUploadId: job.clientUploadId,
        status:         job.status,
        progress:       job.progress,
        url:            job.url,
        error:          job.error,
        // Optimistic preview is owned by the job (survives unmount/remount and
        // reload); fall back to the S3 url once the transfer completes.
        preview:        job.url || job.localPreview() || null,
        isError,
        isReady:        !isError && !inProgress,
        isRetryable:    job.status === 'retryableError',
        inProgress
      };
    },

    summary() {
      let pending = 0;
      let failed = 0;
      for (const item of this.items) {
        if (item.isError) failed++;
        else if (!item.isReady) pending++;
      }
      return { pending, failed };
    }
  },
  mounted() {
    // One subscription: the manager notifies on every job transition.
    this._unsub = this.$uploads.subscribe(() => this.refresh());
  },
  beforeDestroy() {
    // Preview objectURLs are owned by the jobs (manager-scoped), not this
    // component, so they survive unmount/remount — nothing to revoke here.
    if (this._unsub) this._unsub();
  }
}
</script>

<style scoped>
.app-uploader__trigger {
  display: inline-block;
  color: var(--main-color);
  cursor: pointer;
  font-size: var(--text-base);
}

.app-uploader__hidden-input {
  display: none;
}

.app-uploader__grid {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2);
  margin-top: var(--space-2);
}

.app-uploader__item {
  position: relative;
  width: 88px;
  height: 88px;
  border-radius: var(--radius-sm);
  overflow: hidden;
  border: 1px solid var(--neutral);
}

.app-uploader__item--error {
  border-color: var(--danger);
}

.app-uploader__thumb {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.app-uploader__thumb--empty {
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--neutral);
  font-size: var(--text-2xl);
  background: var(--main-color-faded);
}

.app-uploader__veil {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-1);
  background: rgba(0, 0, 0, 0.35);
  color: #fff;
}

.app-uploader__veil--error {
  background: rgba(0, 0, 0, 0.45);
}

.app-uploader__spinner {
  color: #fff;
}

.app-uploader__pct {
  font-size: var(--text-xs);
}

.app-uploader__error-icon {
  color: var(--danger);
  font-size: var(--text-2xl);
}

.app-uploader__actions {
  position: absolute;
  top: var(--space-1);
  right: var(--space-1);
  display: flex;
  gap: var(--space-1);
}

.app-uploader__action {
  color: #fff;
  font-size: var(--text-lg);
  cursor: pointer;
  filter: drop-shadow(0 1px 1px rgba(0, 0, 0, 0.6));
}
</style>
