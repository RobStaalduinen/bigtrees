<template>
  <div class="image-thumb" @click="$emit('click', image.id)">
    <span class="drag-handle">⠿</span>

    <img v-if="displayUrl" :src="displayUrl" :alt="image.id" class="thumb-img" />
    <div v-else class="thumb-img thumb-img--empty">
      <b-icon icon="image"></b-icon>
    </div>

    <!-- Still processing on the server (no ready URL yet). The uploader sees a
         live progress bar over their own local preview; other viewers see the
         same overlay over an empty tile. Either way the upload can be killed. -->
    <div
      v-if="isPending"
      class="thumb-overlay"
      :class="{ 'thumb-overlay--error': isError }"
    >
      <template v-if="isError">
        <b-icon icon="exclamation-triangle" class="thumb-overlay-icon"></b-icon>
        <span class="thumb-overlay-label">Upload failed</span>
      </template>
      <template v-else>
        <span class="thumb-overlay-label">Uploading…</span>
        <b-progress
          class="thumb-progress"
          :value="barValue"
          :max="100"
          :striped="barAnimated"
          :animated="barAnimated"
          height="5px"
        ></b-progress>
      </template>

      <b-icon
        icon="x-circle-fill"
        class="thumb-remove"
        :title="isError ? 'Remove' : 'Cancel upload'"
        @click.stop="$emit('remove', image)"
      ></b-icon>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    image: {
      required: true,
      type: Object
    }
  },
  data() {
    return {
      // Mirror of the matched upload job's state — copied into reactive data
      // (the manager itself is plain, non-reactive JS) so the bar updates live.
      hasJob: false,
      jobStatus: null,
      jobProgress: 0,
      localPreview: null
    };
  },
  computed: {
    // What every viewer eventually sees.
    serverUrl() {
      return this.image.edited_image_url || this.image.image_url;
    },
    // Pending = the server image isn't ready yet (placeholder row).
    isPending() {
      return !this.serverUrl;
    },
    // Uploader sees the local preview under the overlay until the real URL lands.
    displayUrl() {
      return this.serverUrl || this.localPreview;
    },
    isError() {
      return this.jobStatus === 'fatalError';
    },
    // Determinate while the bytes are actively transferring with a known %;
    // otherwise (no local job, or a non-numeric phase like finalizing/
    // associating) show an indeterminate striped+animated bar.
    barDeterminate() {
      return this.hasJob && this.jobStatus === 'uploading' && this.jobProgress > 0;
    },
    barAnimated() {
      return !this.barDeterminate;
    },
    barValue() {
      return this.barDeterminate ? this.jobProgress : 100;
    }
  },
  watch: {
    // The row object is replaced on refetch (pending → ready); re-match the job.
    'image.client_upload_id'() {
      this.syncJob();
    }
  },
  methods: {
    syncJob() {
      const job = (this.$uploads && this.image.client_upload_id)
        ? this.$uploads.jobFor(this.image.client_upload_id)
        : null;
      this.hasJob = !!job;
      this.jobStatus = job ? job.status : null;
      this.jobProgress = job ? (job.progress || 0) : 0;
      this.localPreview = job && job.localPreview ? job.localPreview() : null;
    }
  },
  created() {
    // Match before first paint so the uploader's preview shows immediately.
    this.syncJob();
  },
  mounted() {
    // The manager notifies on every job transition (incl. progress).
    if (this.$uploads) this._unsub = this.$uploads.subscribe(() => this.syncJob());
  },
  beforeDestroy() {
    if (this._unsub) this._unsub();
  }
}
</script>

<style scoped>
.image-thumb {
  position: relative;
  max-width: 30%;
  flex-shrink: 0;
  margin-right: 8px;
  cursor: grab;
}

.image-thumb:active {
  cursor: grabbing;
}

.drag-handle {
  position: absolute;
  top: 2px;
  left: 2px;
  color: white;
  background: rgba(0, 0, 0, 0.4);
  border-radius: 2px;
  padding: 0 3px;
  font-size: 12px;
  opacity: 0;
  transition: opacity 0.15s;
  pointer-events: none;
}

.image-thumb:hover .drag-handle {
  opacity: 1;
}

.thumb-img {
  max-width: 100%;
  display: block;
}

.thumb-img--empty {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  min-height: 80px;
  color: var(--neutral);
  font-size: var(--text-2xl);
  background: var(--main-color-faded);
  border-radius: var(--radius-sm);
}

/* Progress veil sits at the bottom so the preview underneath stays visible. */
.thumb-overlay {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
  padding: var(--space-1) var(--space-2) var(--space-2);
  background: linear-gradient(to top, rgba(0, 0, 0, 0.6), rgba(0, 0, 0, 0));
}

.thumb-overlay--error {
  align-items: center;
  inset: 0;
  justify-content: center;
  background: rgba(0, 0, 0, 0.45);
}

.thumb-overlay-label {
  font-size: var(--text-xs);
  color: #fff;
  text-shadow: 0 1px 1px rgba(0, 0, 0, 0.6);
}

.thumb-overlay-icon {
  color: var(--danger);
  font-size: var(--text-2xl);
}

.thumb-progress {
  width: 100%;
}

.thumb-remove {
  position: absolute;
  top: var(--space-1);
  right: var(--space-1);
  color: var(--danger);
  font-size: var(--text-lg);
  cursor: pointer;
  filter: drop-shadow(0 1px 1px rgba(0, 0, 0, 0.6));
}
</style>
