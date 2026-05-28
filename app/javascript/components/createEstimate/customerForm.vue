<template>
  <div>
    <app-input-field
      :value='value.name'
      @input="(value) => update('name', value)"
      name='name'
      label='Name'
      validationRules='required'
    ></app-input-field>

    <app-input-field
      :value='value.email'
      @input="(value) => update('email', value)"
      name='email'
      label='Email'
    ></app-input-field>

    <app-input-field
      :value='value.phone'
      @input="(value) => update('phone', value)"
      name='phone'
      label='Phone Number'
    ></app-input-field>

    <app-select-field
      v-if='showPriority'
      :value='value.priority'
      @input="(value) => update('priority', value)"
      name='priority'
      label='Priority'
      :options='priorityOptions'
    ></app-select-field>
  </div>
</template>

<script>
import SelectField from '../form/selectField';

export default {
  components: {
    'app-select-field': SelectField
  },
  props: {
    value: {
      required: true
    },
    showPriority: {
      type: Boolean,
      default: false
    }
  },
  data(){
    return {
      workingCustomer: {},
      priorityOptions: [
        { value: 1, text: '1 — Highest' },
        { value: 2, text: '2' },
        { value: 3, text: '3' },
        { value: 4, text: '4' },
        { value: 5, text: '5 — Lowest' }
      ]
    }
  },
  methods: {
    update(key, value) {
      this.$emit('input', { ...this.value, [key]: value })
    }
  },
  watch: {
    // workingCustomer: function() {
    //   this.$emit('input', this.workingCustomer)
    // },
    value: function() {
      this.workingCustomer = this.value;
    }
  }
  
}
</script>

<style scoped>

</style>
