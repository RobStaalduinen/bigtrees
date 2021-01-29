<template>
  <div>
    <app-collapsable id='addresss-collapse'>
      <template v-slot:title>
        <b>{{ boxTitle }}</b>
      </template>

      <template v-slot:content>
        <b-row class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Site Addr.</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.site.address.full_address }}
          </b-col>
        </b-row>

        <b-row v-if='estimate.customer.address' class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Billing Addr.</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.customer.address.full_address }}
          </b-col>
        </b-row>

        <div class='single-estimate-link-row'>
          <div class='single-estimate-link' v-b-toggle.address-edit>
            <b-icon icon='pencil-square' class='app-icon'></b-icon>
          </div>
        </div>
      </template>

    </app-collapsable>

    <app-right-sidebar id='address-edit' title='Edit Addresses' submitText='Save' :onSubmit='updateAddress'>
      <template v-slot:content>
        <app-address-form
          v-model='addresses'
          :initialSite='initialSite()'
          :initialBilling='initialBilling()'
          @addressesChanged='(payload) => { addresses = payload }'
        >
        </app-address-form>
      </template>
    </app-right-sidebar>
  </div>
</template>

<script>
import AddressForm from '../createEstimate/addressForm';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-address-form': AddressForm
  },
  props: {
    estimate: {
      required: true,
      type: Object
    }
  },
  data(){
    return {
      addresses: {}
    }
  },
  computed: {
    boxTitle() {
      return this.estimate.customer.address ? 'Addresses (Billing included)' : 'Addresses';
    }
  },
  methods: {
    updateAddress() {
      var params = {
        site: {
          address_attributes: {
            id: this.estimate.site.address.id,
            ... this.addresses.siteAddress
          }
        }
      }
      this.axiosPut(`/estimates/${this.estimate.id}/sites/${this.estimate.site.id}`, params).then(response => {
        EventBus.$emit('ESTIMATE_UPDATED', { site: response.data.site });
        this.updateBillingAddress().then(response => {
          this.$root.$emit('bv::toggle::collapse', 'address-edit');
        })
      })
    },
    updateBillingAddress() {
      var params = {
        customer: {
          address_attributes: {}
        }
      }

      if(!this.estimate.customer.address && !this.addresses.billingAddress) {
        return new Promise((resolve, reject) => { resolve(true) });
      }

      if(this.estimate.customer.address) {
        params.customer.address_attributes.id = this.estimate.customer.address.id
      }

      if(this.addresses.billingAddress) {
        params.customer.address_attributes = {
          ...params.customer.address_attributes,
          ...this.addresses.billingAddress
        }
      }
      else {
        params.customer.address_attributes._destroy = true
      }

      return this.axiosPut(`/customers/${this.estimate.customer.id}`, params).then(response => {
        EventBus.$emit('ESTIMATE_UPDATED', { customer: response.data.customer });
      })
    },
    initialSite() {
      return this.estimate.site.address;
    },
    initialBilling() {
      return this.estimate.customer.address;
    }
  }
}
</script>

<style scoped>

</style>
