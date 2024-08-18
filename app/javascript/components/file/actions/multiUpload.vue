<template>
  <div>
    <b-form-file
      :id='id'
      multple
      :name='name'
      v-model="images"
      placeholder="Choose a file..."
      :accept="accept"
      multiple
      class="text-nowrap text-truncate"
    ></b-form-file>

    <div v-for='(image, index) in images' :key='index' class='file-upload-container'>
      <app-single-uploader
        :id='index'
        :imageToUpload='image'
        :bucketName='bucketName'
        @upload-status-changed='(event) => handleUpload(index, event)'
        @deleted='removeFile(index)'
      ></app-single-uploader>
    </div>
  </div>
</template>

<script>

import SingleUploader from './singleUploader.vue';

export default {
  components: {
    'app-single-uploader': SingleUploader
  },
  props: {
    'id': {
      required: false,
      type: String
    },
    'value': {
      required: true
    },
    'accept': {
      type: String
    },
    'bucketName': {
      type: String,
      default: 'documents'
    },
    'name': {
      type: String,
      default: 'document'
    }
  },
  data() {
    return {
      images: [],
    }
  },
  methods: {
    removeFile(id) {
      this.images.splice(id, 1);
    },
    handleUpload(id, uploadData) {
      console.log('handleUpload', id, uploadData);
      this.images[id] = uploadData;
      this.$emit('input', this.images);
    }
  },
  computed: {

  },
  watch: {

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

  .file-upload-container {
    margin-top: 8px;
  }

  .file-name-field {
    max-width: 80%;
    overflow: hidden;
  }

  #delete-icon {
    color: var(--main-color);
    font-size: 22px;
  }

  #app-loader-container {
    margin-right: 8px;
    color: var(--main-color);
  }
</style>
