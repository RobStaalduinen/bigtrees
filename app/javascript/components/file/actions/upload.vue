<template>
  <div>
    <div v-if='url && !uploading' class='file-field'>
      <div class='file-name-field'>{{ fileName }}</div>
      <b-icon id='delete-icon' icon='x-circle' @click="removeFile"></b-icon>
    </div>

    <div v-if='!url && uploading' class='file-field'>
      <b-spinner id='app-loader-container'></b-spinner> <div class='file-name-field'>Uploading {{ fileName }}</div>
    </div>

    <div v-if='!url && !uploading'>
      <b-form-file
        v-model="imageToUpload"
        placeholder="Choose a file..."
        :accept="accept"
      ></b-form-file>
    </div>
  </div>
</template>

<script>
import { signedUrlFormData, parseImageUploadResponse } from '@/utils/awsS3Utils';
import { fileNameFromPath } from '@/utils/fileUtils';

export default {
  props: [ 'value', 'accept' ],
  data() {
    return {
      url: this.value,
      imageToUpload: null,
      uploading: false
    }
  },
  methods: {
    removeFile() {
      this.url = null;
    },
    uploadFile() {
      this.axiosGet('/files/new', { bucket_name: 'documents', filename: this.fileName }).then(response => {
        const formData = signedUrlFormData(response.data.fields, this.imageToUpload);

        this.axiosImagePost(response.data.url, formData).then(response => {
          this.url = parseImageUploadResponse(response);
          this.uploading = false;
        })
      })
    }
  },
  computed: {
    fileName() {
      if(this.url != null) {
        return fileNameFromPath(this.url);
      }
      else if(this.imageToUpload != null){
        return this.imageToUpload.name;
      }
      else {
        return ''
      }
    }
  },
  watch: {
    value() {
      this.url = this.value;
    },
    imageToUpload() {
      this.uploading = true
      this.uploadFile();
    },
    url() {
      this.$emit('input', this.url);
    }
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
