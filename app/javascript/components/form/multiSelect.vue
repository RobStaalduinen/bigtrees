<template>
  <validation-provider :name="name" :rules="validationRules" v-slot="{ errors }">
    <b-form-group
        :label="label"
        :label-for="name"
        :class='groupClass'
      >

      <multiselect
        v-model="input"
        name='name'
        :options="options"
        :searchable='false'
        :allow-empty='false'
        label='text'
        track-by='value'
        :multiple='true'
        :close-on-select='false'
        :taggable='false'
        :showPointer='false'

      ></multiselect>
      <span class='submit-error'>{{ errors[0] }}</span>
    </b-form-group>
  </validation-provider>
</template>

<script>
export default {
  props: {
    value: {

    },
    options: {
      required: true
    },
    name: {
      type: String,
      required: true
    },
    validationRules: {
      type: String
    },
    label: {
      type: String,
      required: true
    },
    id: {
      type: String
    },
    groupClass: {
      type: String
    },
    inputType: {
      type: String,
      default: 'text'
    },
    maxLength: {
      type: Number,
      default: null
    }
  },
  data() {
    return {
      input: this.value ? this.value : null
    }
  },
  watch: {
    input: function() {
      this.$emit('input', this.input)
    },
    value: function(){
      this.input = this.value;
    }
  },
  methods: {
    getValidationState({ dirty, validated, valid = null }) {
      return !valid && (dirty || validated) ? valid : null;
    }
  }

}
</script>

<style scoped>
  .validation-error {
    font-size: 10px;
    color: red;
    font-style: italic;
  }
</style>
