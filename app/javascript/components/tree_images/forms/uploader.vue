<template>
  <div id='file-field'>
    <div id='file-content-left'>
      <div id='image-content-left'>
        <app-loader v-if="uploadingImage"></app-loader>
        <img v-if="!uploadingImage && imageUrl" class='image-preview' :src='imageUrl' />
      </div>
      <div :class='{"text-loading": uploadingImage}'>{{ file.name }}</div>
      <div v-if='completionPercentage' id='completion-percentage'>({{ completionPercentage }}%)</div>
    </div>

    <b-icon v-if='!uploadingImage' id='delete-icon' icon='x-circle' @click="$emit('delete-image')"></b-icon>
  </div>
</template>

<script>
import imageCompression from 'browser-image-compression';

export default {
  props: {
    file: {
      type: File,
      required: true
    }
  },
  data() {
    return {
      uploadingImage: false,
      imageUrl: null,
      completionPercentage: null
    }
  },
  methods: {
    beginUpload() {
      this.uploadingImage = true
      var fileParams = { filename: this.file.name }
      this.axiosGet('/tree_images/new', fileParams).then(response => {
        var urlResponse = response.data
        this.uploadImage(urlResponse.url, urlResponse.fields)
      })
    },
    uploadImage(base_url, url_fields) {
      const formData = new FormData();
      for ( var key in url_fields ) {
          formData.append(key, url_fields[key]);
      }
      this.compressFile(this.file).then(compressedFile => {
        console.log('Compressed File Size', compressedFile.size);

        formData.append('file', this.file)

        this.axiosImagePost(base_url, formData, this.handleProgress).then(response => {
          var parseString = require('xml2js').parseString;

          parseString(response.data, (err, result) => {
            this.imageUrl = result.PostResponse.Location[0];
            this.uploadingImage = false;
          });
        })
      })      
    },
    compressFile(file) {
      console.log(file);
      const options = {
        maxSizeMB: 1,          // target ≤1MB
        maxWidthOrHeight: 1024,
        useWebWorker: true,
      };

      return imageCompression(file, options)
    },
    handleProgress(percentage) {
      this.completionPercentage = percentage;
    },
  },
  mounted() {
    this.beginUpload();
  },
  computed: {
    fileResponse: function() {
      return {
        url: this.imageUrl,
        uploadCompleted: !this.uploadingImage
      }
    }
  },
  watch: {
    fileResponse: function() {
      this.$emit('input', this.fileResponse);
    }
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

  .text-loading {
    color: gray;
  }

  #delete-icon {
    color: var(--main-color);
    font-size: 22px;
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
