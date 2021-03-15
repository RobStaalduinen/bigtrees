<template>
    <app-right-sidebar :id='id' title='Update Document' submitText='Submit' :onSubmit='updateDocument' @completed='reset'>
    <template v-slot:content>
      <app-input-field
        v-model='name'
        name="name"
        label='Name'
        validationRules='required'
      ></app-input-field>

      <app-single-image v-model='image'></app-single-image>
    </template>
  </app-right-sidebar>
</template>

<script>
import SingleImageForm from '@/components/tree_images/forms/single';

export default {
  components: {
    'app-single-image': SingleImageForm
  },
  props: ['id', 'document'],
  data() {
    return {
      name: null,
      image: {}
    }
  },
  methods: {
    updateDocument() {

    },
    reset() {
      // this.document = null
    },
    setInitial() {
      if(this.document == null) {
        this.name = null;
        this.image = { uploadCompleted: true, url: document.file_url }
        return
      }

      this.name = this.document.name;
    }
  },
  watch: {
    document() {
      this.setInitial();
    },
    image() {
      console.log(this.image);
    }
  }
}
</script>

<style scoped>

</style>
