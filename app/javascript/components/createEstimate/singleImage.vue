<template>
  <div id='file-field'>
    <div id='file-content-left'>
      <div id='image-content-left'>
        <app-loader v-if="uploadingImage"></app-loader>
        <img v-if="!uploadingImage && imageUrl" class='image-preview' :src='imageUrl' />
      </div>
      <div :class='{"text-loading": uploadingImage}'>{{ file.name }}</div>
    </div>

    <b-icon v-if='!uploadingImage' id='delete-icon' icon='x-circle' @click="$emit('delete-image')"></b-icon>
  </div>
</template>

<script>
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
      imageUrl: null
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
      formData.append('file', this.file)

      this.axiosImagePost(base_url, formData).then(response => {
        var parseString = require('xml2js').parseString;

        parseString(response.data, (err, result) => {
          this.imageUrl = result.PostResponse.Location[0];
          this.uploadingImage = false;
        });
      })
    }
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
      console.log(this.fileResponse);
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
</style>
