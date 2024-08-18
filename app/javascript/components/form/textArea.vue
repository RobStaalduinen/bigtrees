<template>
    <b-form-group
        :label="label"
        :label-for="name"
      >
      <b-form-textarea
        :id="id"
        :name="name"
        v-model='text'
        :no-resize='noResize'
        class="form-control"
      ></b-form-textarea>
    </b-form-group>
</template>

<script>
export default {
  props: {
    id: {
      type: String,
      required: false
    },
    name: {
      type: String,
      required: false
    },
    label: {
      type: String,
      required: true
    },
    value: {
      type: String,
      default: ''
    },
    noResize: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      text: this.value
    }
  },
  watch: {
    text() {
      this.$emit('input', this.text);
    }
  }
}
</script>

<style scoped>
.form-group {
  margin-bottom: 1rem;
}
</style>
