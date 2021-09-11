<template>
  <div>
    <app-input-field
      v-model='content'
      name='content'
      label='Content'
    />

    <b-form-group
      label="Image (Optional)"
      label-for="image-file"
    >
      <app-file-upload
        v-model='fileUrl'
        name='image-file'
        id='image-file'
        accept=".jpg, .jpeg, .png"
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
      content: this.value ? this.value.content : null
    }
  },
  computed: {
    noteDefinition() {
      return {
        fileUrl: this.fileUrl,
        content: this.content
      }
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
