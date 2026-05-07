<template>
  <upload-item v-if="job" :job="job" @remove="onRemove"></upload-item>
</template>

<script>
import { UploadJob } from '@/services/UploadJob';
import UploadItemComponent from '../uploadItem.vue';

export default {
  components: { 'upload-item': UploadItemComponent },
  props: {
    id:           { required: false },
    imageToUpload:{ required: true },
    bucketName:   { type: String, default: 'documents' },
    displayProgress: { type: Boolean, default: true }
  },
  data() {
    return { job: null };
  },
  methods: {
    onRemove() {
      if (this.job) this.job.abort();
      this.job = null;
      this.$emit('deleted', { id: this.id });
    },
    _sync(j) {
      this.$emit('upload-status-changed', { id: this.id, uploading: j.status !== 'success' && j.status !== 'fatalError', url: j.url });
    }
  },
  mounted() {
    this.job = new UploadJob(this.imageToUpload, { bucketName: this.bucketName });
    this._unsub = this.job.on(this._sync);
    this.job.start();
  },
  beforeDestroy() {
    if (this._unsub) this._unsub();
  },
  watch: {
    imageToUpload(file) {
      if (this._unsub) this._unsub();
      if (this.job) this.job.abort();
      this.job = new UploadJob(file, { bucketName: this.bucketName });
      this._unsub = this.job.on(this._sync);
      this.job.start();
    }
  }
}
</script>
