<template>
  <div>
    <app-input-field
      v-model='street'
      :name='name + "street"'
      label='Street and Number'
      validationRules='required'
    ></app-input-field>

    <div class='form-row'>
      <div class='half-form-group'>
        <app-input-field
          v-model='city'
          :name='name + "_city"'
          label='City'
          validationRules='required'
        ></app-input-field>
      </div>

      <div class='half-form-group'>
        <app-input-field
          v-model='postal_code'
          :name='name + "_postal_code"'
          label='Postal Code'
          validationRules='required'
        ></app-input-field>
      </div>

    </div>
  </div>  
</template>

<script>
export default {
  props: {
    name: {
      required: true
    },
    initialAddress: {
      default: null
    }
  },
  data(){
    return {
      street: null,
      city: null,
      postal_code: null
    }
  },
  computed: {
    address(){
      return {
        street: this.street,
        city: this.city,
        postal_code: this.postal_code
      }
    }
  },
  watch: {
    address: function() {
      this.$emit('addressChange', this.address);
    },
    initialAddress: function() {
      this.updateInitialAddress();
    }
  },
  methods: {
    updateInitialAddress() {
      if(this.initialAddress) {
        this.street = this.initialAddress.street;
        this.city = this.initialAddress.city;
        this.postal_code = this.initialAddress.postal_code;
      }
    }
  },
  mounted() {
    this.updateInitialAddress();
    this.$emit('addressChange', this.address);
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
