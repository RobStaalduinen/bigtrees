<template>
  <ValidationProvider :name="name" :rules="validationRules" v-slot="valContext">
      <b-form-group
        :label="label"
        :label-for="name"
        :class='groupClass'
      >
        <b-form-datepicker
          :name='name'
          v-model='input'
          :state="getValidationState(valContext)"
          :date-format-options="dateFormatOptions"
          locale='en-CA'
          :id='id'
          autocomplete='off'
          aria-describedby="input-feedback"
        >
        </b-form-datepicker>
      </b-form-group>

      <b-form-invalid-feedback id="input-feedback">{{ valContext.errors[0] }}</b-form-invalid-feedback>
    </b-form-group>
  </ValidationProvider>
</template>

<script>
export default {
  props: {
    value: {

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
    },
    disabled: {
      type: Boolean,
      default: false
    },
    dateFormatOptions: {
      type: Object,
      default: () => { return { year: 'numeric', month: 'numeric', day: 'numeric' } }
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
