<template>
  <div id="file-field" :class="{ 'file-field--error': hasError }">
    <div id="file-content-left">
      <div id="image-content-left">
        <app-loader v-if="inProgress"></app-loader>
        <img v-if="!inProgress && imageUrl" class="image-preview" :src="imageUrl" />
        <b-icon v-if="hasError" icon="exclamation-triangle" class="error-icon"></b-icon>
      </div>
      <div :class="{ 'text-loading': inProgress }">{{ file.name }}</div>
      <div v-if="inProgress && progress" id="completion-percentage">({{ progress }}%)</div>
      <div v-if="hasError" class="error-msg">{{ errorMessage }}</div>
    </div>

    <div class="actions">
      <b-icon v-if="hasError && status === 'retryableError'" icon="arrow-clockwise" class="retry-icon" @click="retry"></b-icon>
      <b-icon v-if="!inProgress" id="delete-icon" icon="x-circle" @click="$emit('delete-image')"></b-icon>
    </div>
  </div>
</template>

<script>
import { UploadJob } from '@/services/UploadJob';

const IN_PROGRESS = new Set(['compressing', 'preparing', 'uploading', 'finalizing']);

export default {
  props: {
    file: { type: File, required: true }
  },
  data() {
    return {
      status:   'idle',
      progress: 0,
      imageUrl: null,
      jobError: null,
      job:      null,
    };
  },
  computed: {
    inProgress()   { return IN_PROGRESS.has(this.status); },
    hasError()     { return this.status === 'retryableError' || this.status === 'fatalError'; },
    errorMessage() { return this.jobError?.message ?? 'Upload failed.'; },
  },
  methods: {
    retry() { this.job?.retry(); }
  },
  mounted() {
    this.job = new UploadJob(this.file, {
      bucketName:  'tree_images',
      presignPath: '/tree_images/new',
    });
    this._unsub = this.job.on(j => {
      this.status   = j.status;
      this.progress = j.progress;
      this.jobError = j.error;
      if (j.status === 'success') this.imageUrl = j.url;
      this.$emit('input', { url: j.url, uploadCompleted: j.status === 'success' });
    });
    this.job.start();
  },
  beforeDestroy() {
    if (this._unsub) this._unsub();
  }
}
</script>

<style>
#file-field {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 8px 0;
  padding: 8px;
  border: 1px lightgray solid;
  font-size: 14px;
}

.file-field--error {
  border-color: #dc3545;
}

.text-loading {
  color: gray;
}

.error-icon {
  color: #dc3545;
  font-size: 18px;
}

.error-msg {
  font-size: 12px;
  color: #dc3545;
  margin-left: 8px;
}

.actions {
  display: flex;
  align-items: center;
  gap: 6px;
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

.image-preview {
  max-width: 50px;
}

#file-content-left {
  display: flex;
}

#image-content-left {
  margin-right: 8px;
}

#completion-percentage {
  margin-left: 8px;
  color: gray;
}
</style>
