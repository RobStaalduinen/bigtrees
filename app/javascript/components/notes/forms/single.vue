<template>
  <div>
    <app-text-area
        v-model='content'
        name='content'
        label='Content'
        validationRules='required'
        :maxLength='65'
        :noResize='true'
      ></app-text-area>

    <b-form-group
      label="Image (Optional)"
      label-for="image-file"
    >
      <app-file-upload
        v-model='fileUrl'
        name='image-file'
        id='image-file'
        accept=".jpg, .jpeg, .png"
        @upload-status-changed='(status) => trackUpload(status)'
      ></app-file-upload>
    </b-form-group>
  </div>
</template>

<script>
import FileUpload from '@/components/file/actions/upload';

export default {
  props: {
    value: {
      type: Object
    }
  },
  components: {
    'app-file-upload': FileUpload
  },
  data() {
    return {
      fileUrl: this.value ? this.value.fileUrl : null,
      fileUploading: false,
      content: this.value ? this.value.content : null
    }
  },
  computed: {
    noteDefinition() {
      return {
        fileUrl: this.fileUrl,
        content: this.content,
        uploading: this.fileUploading
      }
    }
  },
  methods: {
    trackUpload(status) {
      this.fileUploading = status;
    }
  },
  watch: {
    noteDefinition() {
      this.$emit('input', this.noteDefinition);
    }
  }
}
</script>

<style scoped>

</style>
