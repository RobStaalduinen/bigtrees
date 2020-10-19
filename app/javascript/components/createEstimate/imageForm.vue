<template>
  <div>

    <app-single-image 
      v-for='(file, index) in selectedFiles' 
      :key='index'
      :file='file'
      :index='index'
      v-model='uploadedFiles[index]'
      @delete-image='deleteImage(index)'
    >

    </app-single-image>

    <hr>
    <div>
      <b-form-file
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
  data() {
    return {
      initialImage: null,
      uploadedFiles: [],
      selectedFiles: []
    }
  },
  methods: {
    queueFile() {
      if(this.initialImage != null) { 
        this.uploadedFiles.push({ uploadFinished: false });
        this.selectedFiles.push(new File([this.initialImage], this.initialImage.name));
        this.$nextTick(() => {
          this.initialImage = null;
        })  
      }
    },
    deleteImage(index) {
      this.selectedFiles.splice(index, 1);
      this.uploadedFiles.splice(index, 1);
    }
  },
  watch: {
    uploadedFiles: function() {
      this.$emit('input', this.uploadedFiles);
    }
  }
}
</script>

<style scoped>

</style>
