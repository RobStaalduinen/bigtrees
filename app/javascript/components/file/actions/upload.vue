<template>
  <div>
    <div v-if='url && !uploading' class='file-field'>
      <div class="file-info-container">
        <img v-if="isImage" :src="url" class="image-thumbnail" />
        <div class='file-name-field'>{{ fileName }}</div>
      </div>
      <b-icon id='delete-icon' icon='x-circle' @click="removeFile"></b-icon>
    </div>

    <div v-if='!url && uploading' class='file-field'>
      <b-spinner id='app-loader-container'></b-spinner> 
      <div class='file-name-field'>Uploading {{ fileName }}</div>
      <div v-if='displayProgress && completionPercentage'>{{ completionPercentage }}%</div>
    </div>

    <div v-if='!url && !uploading'>
      <b-form-file
        :id='id'
        :name='name'
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
import imageCompression from 'browser-image-compression';

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
      default: 'documents'
    },
    'name': {
      type: String,
      default: 'document'
    },
    'displayProgress': {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      url: this.value,
      imageToUpload: null,
      uploading: false,
      completionPercentage: null
    }
  },
  methods: {
    removeFile() {
      this.url = null;
      this.uploading = false;
      this.$emit('input', null);
    },
    uploadFile() {
      this.axiosGet('/files/new', { bucket_name: this.bucketName, filename: this.fileName }).then(response => {
        this.compressFile(this.imageToUpload).then(compressedFile => {
          const formData = signedUrlFormData(response.data.fields, compressedFile);
          
          this.axiosImagePost(response.data.url, formData, this.handleProgress).then(response => {
            let url = parseImageUploadResponse(response);
            this.url = url;
            this.uploading = false;
            this.$emit('input', url);
          })
        })
      })
    },
    handleProgress(percentage) {
      this.completionPercentage = percentage;
    },
    compressFile(file) {
      if (!file.type.match(/image\/*/)) {
        return Promise.resolve(file);
      }

      const options = {
        maxSizeMB: 1,          // target ≤1MB
        maxWidthOrHeight: 1024,
        useWebWorker: true,
      };

      return imageCompression(file, options)
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
    },
    isImage() {
      if (!this.fileName) return false;
      const extension = this.fileName.split('.').pop().toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(extension);
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
    uploading() {
      this.$emit('upload-status-changed', this.uploading)
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

  .thumbnail {
    height: 40px;
    width: 40px;
    object-fit: cover;
    border-radius: 4px;
  }
</style>
