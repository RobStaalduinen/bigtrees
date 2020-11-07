<template>
  <div>
    <span>Site Address</span>
    <app-single-address-form
      :initialAddress='initialSite'
      @addressChange='(payload) => {siteAddress = payload}'
      name='site'
    ></app-single-address-form>

    <div v-if='billingAddressRequired'>
      <div id='business-header-row'>
        <span>Billing Address</span>
        <a @click.prevent='billingAddressRequired=false' class='toggle-link'>Remove</a>
      </div>
      <app-single-address-form
        :initialAddress='initialBilling'
        @addressChange='(payload) => {billingAddress = payload}'
        name='billing'
      ></app-single-address-form>
    </div>
    <div v-else id='business-toggle' class='toggle-link'>
      <a @click.prevent='billingAddressRequired = true'>+ Add Billing Address +</a>
    </div>
  </div>
</template>

<script>
import SingleAddressForm from './singleAddressForm';

export default {
  props: ['initialSite', 'initialBilling'],
  components: {
    'app-single-address-form': SingleAddressForm
  },
  data(){
    return {
      billingAddressRequired:  false,
      siteAddress: { ...this.initialSite},
      billingAddress: { ...this.initialBilling }
    }
  },
  computed: {
    addresses() {
      var merged = { siteAddress: { ...this.siteAddress } }
      if(this.billingAddressRequired){
        merged.billingAddress = { ...this.billingAddress };
      }
      return merged;
    }
  },
  watch: {
    addresses: function() {
      this.$emit('addressesChanged', this.addresses);
    },
    initialBilling() {
      if(this.initialBilling) {
        this.billingAddressRequired = true;
      }
    },
    initialSite() {
      this.$forceUpdate();
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
