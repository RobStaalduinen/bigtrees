<template>
  <upload-list
    :id="id"
    :name="name"
    :accept="accept"
    :bucketName="bucketName"
    :value="value"
    @input="$emit('input', $event)"
  ></upload-list>
</template>

<script>
import UploadList from '../uploadList.vue';

export default {
  components: { 'upload-list': UploadList },
  props: {
    id:         { type: String,  required: false },
    name:       { type: String,  default: 'document' },
    accept:     { type: String,  required: false },
    bucketName: { type: String,  default: 'documents' },
    value:      { required: true }
  }
}
</script>
