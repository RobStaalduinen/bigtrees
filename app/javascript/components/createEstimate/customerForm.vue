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
  </div>  
</template>

<script>
export default {
  props: ['value'],
  data(){
    return {
      workingCustomer: {}
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
