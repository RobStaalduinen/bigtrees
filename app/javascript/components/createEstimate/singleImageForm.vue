<template>
  <div>
    <app-single-image
      v-if='selectedFile'
      :file='selectedFile'
      v-model='uploadedFile'
      @delete-image='deleteImage'
    >
    </app-single-image>
    <div>
      <b-form-file
        v-if="!selectedFile"
        v-model="initialImage"
        placeholder="Choose a file..."
        @input='queueFile'
        accept=".jpg, .jpeg, .png"
      ></b-form-file>
    </div>
  </div>
</template>

<script>
import SingleImage from './singleImage';
export default {
  components: {
    'app-single-image': SingleImage
  },
  props: [ 'value' ],
  data() {
    return {
      initialImage: null,
      uploadedFile: null,
      selectedFile: null
    }
  },
  methods: {
    queueFile() {
      if(this.initialImage != null) {
        this.uploadedFile = { uploadFinished: false };
        this.selectedFile = new File([this.initialImage], this.initialImage.name);
        this.$nextTick(() => {
          this.initialImage = null;
        })
      }
    },
    deleteImage() {
      this.selectedFile = null;
      this.uploadedFile = null;
      this.initialImage = null
    }
  },
  watch: {
    uploadedFile: function() {
      this.$emit('input', this.uploadedFile);
    }
  }
}
</script>

<style scoped>

</style>
