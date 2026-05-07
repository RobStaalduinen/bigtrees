<template>
  <div v-if="status !== 'cancelled'" class="upload-item" :class="itemClass">
    <div class="upload-item__left">
      <img v-if="status === 'success' && isImage" :src="url" class="upload-item__thumb" />
      <b-spinner v-else-if="inProgress" small class="upload-item__spinner"></b-spinner>
      <b-icon v-else-if="hasError" icon="exclamation-triangle" class="upload-item__error-icon"></b-icon>

      <div class="upload-item__info">
        <div class="upload-item__name">{{ fileName }}</div>
        <div v-if="inProgress && progress" class="upload-item__progress">{{ progress }}%</div>
        <div v-if="hasError" class="upload-item__error-msg">{{ errorMessage }}</div>
      </div>
    </div>

    <div class="upload-item__actions">
      <b-icon
        v-if="status === 'retryableError'"
        icon="arrow-clockwise"
        class="upload-item__retry"
        @click="retry"
      ></b-icon>
      <b-icon
        v-if="status !== 'compressing' && status !== 'preparing'"
        icon="x-circle"
        class="upload-item__remove"
        @click="remove"
      ></b-icon>
    </div>
  </div>
</template>

<script>
import { fileNameFromPath } from '@/utils/fileUtils';

const IN_PROGRESS = new Set(['compressing', 'preparing', 'uploading', 'finalizing']);

export default {
  props: {
    job: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      status:   this.job.status,
      progress: this.job.progress,
      url:      this.job.url,
      error:    this.job.error,
    };
  },
  computed: {
    inProgress() { return IN_PROGRESS.has(this.status); },
    hasError()   { return this.status === 'retryableError' || this.status === 'fatalError'; },
    fileName() {
      if (this.url) return fileNameFromPath(this.url);
      return this.job.file?.name ?? '';
    },
    isImage() {
      const ext = this.fileName.split('.').pop().toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(ext);
    },
    errorMessage() {
      return this.error?.message ?? 'Upload failed.';
    },
    itemClass() {
      return {
        'upload-item--error': this.hasError,
        'upload-item--success': this.status === 'success',
      };
    }
  },
  methods: {
    retry()  { this.job.retry(); },
    remove() {
      this.job.abort();
      this.$emit('remove', this.job.id);
    }
  },
  mounted() {
    this._unsub = this.job.on(job => {
      this.status   = job.status;
      this.progress = job.progress;
      this.url      = job.url;
      this.error    = job.error;
    });
  },
  beforeDestroy() {
    if (this._unsub) this._unsub();
  }
}
</script>

<style scoped>
.upload-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px;
  margin-top: 8px;
  border: 1px lightgray solid;
}

.upload-item--error {
  border-color: #dc3545;
}

.upload-item__left {
  display: flex;
  align-items: center;
  overflow: hidden;
  flex: 1;
}

.upload-item__thumb {
  height: 40px;
  width: 40px;
  object-fit: cover;
  border-radius: 4px;
  margin-right: 8px;
  flex-shrink: 0;
}

.upload-item__spinner {
  margin-right: 8px;
  color: var(--main-color);
  flex-shrink: 0;
}

.upload-item__error-icon {
  color: #dc3545;
  font-size: 18px;
  margin-right: 8px;
  flex-shrink: 0;
}

.upload-item__info {
  overflow: hidden;
}

.upload-item__name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 14px;
}

.upload-item__progress {
  font-size: 12px;
  color: gray;
}

.upload-item__error-msg {
  font-size: 12px;
  color: #dc3545;
}

.upload-item__actions {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-shrink: 0;
  margin-left: 8px;
}

.upload-item__retry {
  color: var(--main-color);
  font-size: 20px;
  cursor: pointer;
}

.upload-item__remove {
  color: var(--main-color);
  font-size: 22px;
  cursor: pointer;
}
</style>
