<template>
  <div>
    <app-input-field
      v-model='workingCustomer.name'
      name='name'
      label='Name'
      validationRules='required'
    ></app-input-field>

    <app-input-field
      v-model='workingCustomer.email'
      name='email'
      label='Email'
    ></app-input-field>

    <app-input-field
      v-model='workingCustomer.phone'
      name='phone'
      label='Phone Number'
    ></app-input-field>
  </div>  
</template>

<script>
export default {
  props: {
    customer: {
      type: Object,
      default: () => { return {} }
    }
  },
  data(){
    return {
      workingCustomer: this.customer
    }
  },
  watch: {
    workingCustomer: function() {
      this.$emit('input', this.workingCustomer)
    }
  }
  
}
</script>

<style scoped>

</style>
