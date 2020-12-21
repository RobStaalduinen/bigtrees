<template>
  <b-button
    type='submit'
    block
    class='submit-button'
    @click='onClick'
    v-if='!submitting'
    >
      {{ label }}
    </b-button>
    <div v-else>
      <b-spinner id='submit-button-loader'></b-spinner>
    </div>
</template>

<script>
export default {
  props: {
    label: {
      type: String,
      required: true
    },
    onSubmit: {
      type: Function,
      required: false,
      default: null
    }
  },
  data() {
    return {
      submitting: false
    }
  },
  methods: {
    onClick() {
      this.submitting = true;
      if(this.onSubmit != null) {
        this.onSubmit();
      }
    }
  }
}
</script>

<style>
  #submit-button-loader {
    color: var(--main-color);
  }
</style>
