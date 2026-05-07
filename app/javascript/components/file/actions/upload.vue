<template>
  <div>
    <!-- Success state -->
    <div v-if="jobStatus === 'success'" class="file-field">
      <div class="file-info-container">
        <img v-if="isImage" :src="url" class="image-thumbnail" />
        <div class="file-name-field">{{ fileName }}</div>
      </div>
      <b-icon id="delete-icon" icon="x-circle" @click="removeFile"></b-icon>
    </div>

    <!-- In-progress state -->
    <div v-else-if="inProgress" class="file-field">
      <b-spinner id="app-loader-container"></b-spinner>
      <div class="file-name-field">{{ statusLabel }}</div>
      <div v-if="displayProgress && progress">{{ progress }}%</div>
    </div>

    <!-- Error state -->
    <div v-else-if="hasError" class="file-field file-field--error">
      <div class="file-info-container">
        <b-icon icon="exclamation-triangle" class="error-icon"></b-icon>
        <div class="file-name-field">{{ errorMessage }}</div>
      </div>
      <div class="file-field__actions">
        <b-icon v-if="jobStatus === 'retryableError'" icon="arrow-clockwise" class="retry-icon" @click="retry"></b-icon>
        <b-icon icon="x-circle" id="delete-icon" @click="removeFile"></b-icon>
      </div>
    </div>

    <!-- Idle: file picker -->
    <div v-else>
      <b-form-file
        :id="id"
        :name="name"
        v-model="imageToUpload"
        placeholder="Choose a file..."
        :accept="accept"
      ></b-form-file>
    </div>
  </div>
</template>

<script>
import { UploadJob } from '@/services/UploadJob';
import { fileNameFromPath } from '@/utils/fileUtils';

const IN_PROGRESS = new Set(['compressing', 'preparing', 'uploading', 'finalizing']);

export default {
  props: {
    id:             { required: false, type: String },
    value:          { required: false },
    accept:         { type: String },
    bucketName:     { type: String, default: 'documents' },
    name:           { type: String, default: 'document' },
    displayProgress:{ type: Boolean, default: true }
  },
  data() {
    return {
      url:          this.value,
      imageToUpload: null,
      job:          null,
      jobStatus:    'idle',
      progress:     0,
      jobError:     null,
    };
  },
  computed: {
    inProgress() { return IN_PROGRESS.has(this.jobStatus); },
    hasError()   { return this.jobStatus === 'retryableError' || this.jobStatus === 'fatalError'; },
    statusLabel() {
      const labels = { compressing: 'Compressing…', preparing: 'Preparing…', uploading: 'Uploading…', finalizing: 'Finalizing…' };
      return `${labels[this.jobStatus] ?? 'Uploading…'} ${this.fileName}`;
    },
    errorMessage() { return this.jobError?.message ?? 'Upload failed.'; },
    fileName() {
      if (this.url) return fileNameFromPath(this.url);
      return this.imageToUpload?.name ?? '';
    },
    isImage() {
      const ext = this.fileName.split('.').pop().toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(ext);
    }
  },
  methods: {
    removeFile() {
      if (this.job) { this.job.abort(); this._unsub?.(); this.job = null; }
      this.url = null;
      this.imageToUpload = null;
      this.jobStatus = 'idle';
      this.$emit('input', null);
      this.$emit('upload-status-changed', false);
    },
    retry() { this.job?.retry(); },
    _startJob(file) {
      if (this._unsub) this._unsub();
      if (this.job) this.job.abort();
      this.job = new UploadJob(file, { bucketName: this.bucketName });
      this._unsub = this.job.on(j => {
        this.jobStatus = j.status;
        this.progress  = j.progress;
        this.jobError  = j.error;
        if (j.status === 'success') {
          this.url = j.url;
          this.$emit('input', j.url);
        }
        const uploading = IN_PROGRESS.has(j.status);
        this.$emit('upload-status-changed', uploading);
        if (j.status === 'retryableError' || j.status === 'fatalError') {
          this.$emit('upload-error', j.error);
        }
      });
      this.job.start();
    }
  },
  watch: {
    value() { this.url = this.value; },
    imageToUpload(file) {
      if (!file) return;
      this._startJob(file);
    }
  },
  beforeDestroy() {
    if (this._unsub) this._unsub();
  }
}
</script>

<style scoped>
.file-field {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px;
  border: 1px lightgray solid;
}

.file-field--error {
  border-color: #dc3545;
}

.file-name-field {
  max-width: 80%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.image-thumbnail {
  height: 40px;
  width: 40px;
  object-fit: cover;
  border-radius: 4px;
  margin-right: 8px;
}

#delete-icon {
  color: var(--main-color);
  font-size: 22px;
  cursor: pointer;
}

.retry-icon {
  color: var(--main-color);
  font-size: 20px;
  cursor: pointer;
}

.error-icon {
  color: #dc3545;
  font-size: 18px;
  margin-right: 8px;
}

#app-loader-container {
  margin-right: 8px;
  color: var(--main-color);
}

.file-info-container {
  display: flex;
  align-items: center;
  overflow: hidden;
  max-width: 80%;
}

.file-field__actions {
  display: flex;
  align-items: center;
  gap: 6px;
}
</style>
