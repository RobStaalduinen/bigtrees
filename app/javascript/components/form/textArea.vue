<template>
    <b-form-group
        :label="label"
        :label-for="name"
        :class='groupClass'
      >
      <b-form-textarea
        :id="id"
        :name="name"
        :value="value"
        :no-resize='noResize'
        class="form-control"
        @input="updateValue"
      ></b-form-textarea>
    </b-form-group>
</template>

<script>
export default {
  props: {
    id: {
      type: String,
      required: true
    },
    name: {
      type: String,
      required: true
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
  methods: {
    updateValue(event) {
      this.$emit('input', event.target.value);
    }
  }
}
</script>

<style scoped>
.form-group {
  margin-bottom: 1rem;
}
</style>
