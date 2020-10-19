<template>
  <div>
    <span>Site Address</span>
    <app-single-address-form v-model='siteAddress'></app-single-address-form>

    <div v-if='billingAddressRequired'>
      <div id='business-header-row'>
        <span>Billing Address</span>
        <a @click.prevent='billingAddressRequired=false' class='toggle-link'>Remove</a>
      </div>
      <app-single-address-form v-model='billingAddress'></app-single-address-form>
    </div>
    <div v-else id='business-toggle' class='toggle-link'>
      <a @click.prevent='billingAddressRequired = true'>+ Add Billing Address +</a>
    </div>
  </div>  
</template>

<script>
import SingleAddressForm from './singleAddressForm';

export default {
  components: {
    'app-single-address-form': SingleAddressForm
  },
  data(){
    return {
      billingAddressRequired: false,
      siteAddress: {},
      billingAddress: {}
    }
  },
  computed: {
    addresses() {
      var merged = { siteAddress: this.siteAddress }
      if(this.billingAddressRequired){
        merged.billingAddress = this.billingAddress;
      }

      return merged;
    }
  },
  watch: {
    addresses: function() {
      this.$emit('input', this.addresses);
    }
  }
  
}
</script>

<style scoped>
  #business-header-row {
    display: flex;
    justify-content: space-between;
  }

  #business-toggle {
    width: 100%;
    display: flex;
    justify-content: center;
  }

  .toggle-link {
    color: var(--main-color);
  }



</style>
