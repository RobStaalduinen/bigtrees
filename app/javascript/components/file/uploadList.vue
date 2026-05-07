<template>
  <div>
    <b-form-file
      :id="id"
      :name="name"
      multiple
      placeholder="Choose a file..."
      :accept="accept"
      class="text-nowrap text-truncate"
      @input="onFilesSelected"
    ></b-form-file>

    <upload-item
      v-for="job in jobs"
      :key="job.id"
      :job="job"
      @remove="removeJob"
    ></upload-item>
  </div>
</template>

<script>
import { UploadJob } from '@/services/UploadJob';
import UploadItemComponent from './uploadItem.vue';

export default {
  components: {
    'upload-item': UploadItemComponent
  },
  props: {
    id:         { type: String,  required: false },
    name:       { type: String,  default: 'document' },
    accept:     { type: String,  required: false },
    bucketName: { type: String,  default: 'documents' },
    presignPath:{ type: String,  default: '/files/new' },
    value:      { required: false }
  },
  data() {
    return {
      jobs: []
    };
  },
  methods: {
    onFilesSelected(files) {
      if (!files || !files.length) return;
      for (const file of (Array.isArray(files) ? files : [files])) {
        const job = new UploadJob(file, {
          bucketName:  this.bucketName,
          presignPath: this.presignPath,
        });
        job.on(() => this._emitValue());
        this.jobs.push(job);
        job.start();
      }
    },
    removeJob(id) {
      this.jobs = this.jobs.filter(j => j.id !== id);
      this._emitValue();
    },
    _emitValue() {
      this.$emit('input', this.jobs.map(j => ({
        id:       j.id,
        status:   j.status,
        url:      j.url,
        progress: j.progress,
      })));
    }
  },
  mounted() {
    window.addEventListener('online',  this._onOnline);
    window.addEventListener('offline', this._onOffline);
  },
  beforeDestroy() {
    window.removeEventListener('online',  this._onOnline);
    window.removeEventListener('offline', this._onOffline);
  },
  created() {
    this._onOnline  = () => { this.jobs.filter(j => j.status === 'retryableError').forEach(j => j.retry()); };
    this._onOffline = () => { this.jobs.filter(j => ['compressing','preparing','uploading','finalizing'].includes(j.status)).forEach(j => j.pause()); };
  }
}
</script>
