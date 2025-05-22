<template>
  <div>
    <div v-if='url && !uploading' class='file-field'>
      <div class='file-name-field'>{{ fileName }}</div>
      <b-icon id='delete-icon' icon='x-circle' @click="removeFile"></b-icon>
    </div>

    <div v-if='!url && uploading' class='file-field'>
      <b-spinner id='app-loader-container'></b-spinner> 
      <div class='file-name-field'>Uploading {{ fileName }}</div>
      <div v-if='completionPercentage'>{{ completionPercentage }}%</div>
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
      type: Number
    },
    'imageToUpload': {
      required: true
    },
    'bucketName': {
      type: String,
      default: 'documents'
    }
  },
  data() {
    return {
      uploading: false,
      url: null,
      completionPercentage: null
    }
  },
  methods: {
    removeFile() {
      this.url = null;
      this.uploading = false;
      this.$emit('deleted', { id: this.id } );
    },
    uploadFile() {
      this.axiosGet('/files/new', { bucket_name: this.bucketName, filename: this.fileName }).then(response => {
        // const formData = signedUrlFormData(response.data.fields, this.imageToUpload);

        this.compressFile(this.imageToUpload).then(compressedFile => {
          // formData.append('file', compressedFile);
          console.log('Compressed File Size', compressedFile.size);
          const formData = signedUrlFormData(response.data.fields, compressedFile);
          
          this.axiosImagePost(response.data.url, formData, this.handleProgress).then(response => {
            this.url = parseImageUploadResponse(response);
            this.uploading = false;
          })
        })
      })
    },
    handleProgress(percentage) {
      this.completionPercentage = percentage;
    },
    compressFile(file) {
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
    }
  },
  watch: {
    uploading() {
      this.$emit('upload-status-changed', { id: this.id, uploading: this.uploading, url: this.url })
    },
    imageToUpload() {
      this.uploading = true
      this.uploadFile();
    }
  },
  mounted() {
    this.uploading = true
    this.uploadFile();
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
    max-width: 70%;
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
