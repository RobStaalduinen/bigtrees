<template>
  <div>
    <!-- Success state -->
    <div v-if="jobStatus === 'success'" class="file-field">
      <span class="pre-upload-label" v-if="label != null">{{ label }}</span>
      <div class="field-interior">
        <img :src="url" class="preview-image" />
        <div class="file-name-field">{{ fileName }}</div>
        <b-icon id="delete-icon" icon="x-circle" @click="removeFile"></b-icon>
      </div>
    </div>

    <!-- In-progress state -->
    <div v-else-if="inProgress" class="file-field">
      <span class="pre-upload-label" v-if="label != null">{{ label }}</span>
      <div class="field-interior">
        <b-spinner id="app-loader-container"></b-spinner>
        <div class="file-name-field">Uploading {{ fileName }}</div>
      </div>
    </div>

    <!-- Error state -->
    <div v-else-if="hasError" class="file-field file-field--error">
      <span class="pre-upload-label" v-if="label != null">{{ label }}</span>
      <div class="field-interior">
        <b-icon icon="exclamation-triangle" class="error-icon"></b-icon>
        <div class="file-name-field">{{ errorMessage }}</div>
        <b-icon v-if="jobStatus === 'retryableError'" icon="arrow-clockwise" class="retry-icon" @click="retry"></b-icon>
        <b-icon icon="x-circle" id="delete-icon" @click="removeFile"></b-icon>
      </div>
    </div>

    <!-- Idle: file picker -->
    <div v-else>
      <div class="file-field">
        <div class="pre-upload-label" v-if="label != null">{{ label }}</div>
        <div class="field-interior">
          <b-form-file
            :id="id"
            :name="name"
            v-model="imageToUpload"
            placeholder="Choose a file..."
            :accept="accept"
          ></b-form-file>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { UploadJob } from '@/services/UploadJob';
import { fileNameFromPath } from '@/utils/fileUtils';

const IN_PROGRESS = new Set(['compressing', 'preparing', 'uploading', 'finalizing']);

export default {
  props: {
    id:         { required: false, type: String },
    value:      { required: false },
    accept:     { type: String },
    bucketName: { type: String, default: 'tree_images' },
    name:       { type: String, default: 'tree_image' },
    label:      { type: String, default: null }
  },
  data() {
    return {
      url:          this.value,
      imageToUpload: null,
      job:          null,
      jobStatus:    'idle',
      jobError:     null,
    };
  },
  computed: {
    inProgress() { return IN_PROGRESS.has(this.jobStatus); },
    hasError()   { return this.jobStatus === 'retryableError' || this.jobStatus === 'fatalError'; },
    errorMessage(){ return this.jobError?.message ?? 'Upload failed.'; },
    fileName() {
      if (this.url) return fileNameFromPath(this.url);
      return this.imageToUpload?.name ?? '';
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
      this.job = new UploadJob(file, { compress: false, bucketName: this.bucketName });
      this._unsub = this.job.on(j => {
        this.jobStatus = j.status;
        this.jobError  = j.error;
        if (j.status === 'success') {
          this.url = j.url;
          this.$emit('input', j.url);
        }
        this.$emit('upload-status-changed', IN_PROGRESS.has(j.status));
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
  border: 1px lightgray solid;
  display: flex;
  flex-direction: column;
}

.file-field--error {
  border-color: #dc3545;
}

.field-interior {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px;
  background-color: #eeeeee;
}

.pre-upload-label {
  font-size: 14px;
  line-height: 14px;
  color: var(--main-color);
  padding: 4px;
  font-weight: 600;
}

.preview-image {
  height: 30px;
  width: auto;
}

.file-name-field {
  max-width: 80%;
  overflow: hidden;
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
</style>
