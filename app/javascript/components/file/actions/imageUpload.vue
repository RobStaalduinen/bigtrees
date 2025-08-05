<template>
  <div>
    <div v-if='url && !uploading' class='file-field'>
      <span class='pre-upload-label' v-if='label != null'>{{ label }}</span>

      <div class='field-interior'>
        <img :src='url' class='preview-image' />
        <div class='file-name-field'>{{ fileName }}</div>
        <b-icon id='delete-icon' icon='x-circle' @click="removeFile"></b-icon>
      </div>
    </div>

    <div v-if='!url && uploading' class='file-field'>
      <span class='pre-upload-label' v-if='label != null'>{{ label }}</span>

      <div class='field-interior'>
        <b-spinner id='app-loader-container'></b-spinner> <div class='file-name-field'>Uploading {{ fileName }}</div>
      </div>
    </div>

    <div v-if='!url && !uploading'>
      <div class='file-field'>
        <div class='pre-upload-label' v-if='label != null'>{{ label }}</div>
        <div class='field-interior'>
          <b-form-file
            :id='id'
            :name='name'
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
import { signedUrlFormData, parseImageUploadResponse } from '@/utils/awsS3Utils';
import { fileNameFromPath } from '@/utils/fileUtils';

export default {
  props: {
    'id': {
      required: false,
      type: String
    },
    'value': {
      required: false
    },
    'accept': {
      type: String
    },
    'bucketName': {
      type: String,
      default: 'tree_images'
    },
    'name': {
      type: String,
      default: 'tree_image'
    },
    'label': {
      type: String,
      default: null
    }
  },
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
      this.uploading = false;
    },
    uploadFile() {
      this.axiosGet('/files/new', { bucket_name: this.bucketName, filename: this.fileName }).then(response => {
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
    },
    uploading() {
      this.$emit('upload-status-changed', this.uploading)
    }
  }
}
</script>

<style scoped>
  .file-field {
    border: 1px lightgray solid;
    display: flex;
    flex-direction: column;
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
  }

  #app-loader-container {
    margin-right: 8px;
    color: var(--main-color);
  }
</style>
