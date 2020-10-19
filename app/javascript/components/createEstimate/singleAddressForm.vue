<template>
  <div>
    <app-input-field
      v-model='address.street'
      name='street'
      label='Street and Number'
      validationRules='required'
    ></app-input-field>

    <div class='form-row'>
      <div class='half-form-group'>
        <app-input-field
          v-model='address.city'
          name='city'
          label='City'
          validationRules='required'
        ></app-input-field>
      </div>

      <div class='half-form-group'>
        <app-input-field
          v-model='address.postal_code'
          name='postal_code'
          label='Postal Code'
          validationRules='required'
        ></app-input-field>
      </div>

    </div>
  </div>  
</template>

<script>
export default {
  data(){
    return {
      address: {}
    }
  },
  watch: {
    address: function() {
      this.$emit('input', this.address);
    }
  }
  
}
</script>

<style scoped>
  .form-row{
    display: flex;
    justify-content: space-between;
    padding: 0 4px;
  }

  .half-form-group{
    width: 48%;
  }
</style>
