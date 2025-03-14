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
            <a :href="'http://maps.google.com/?q=' + encodeAddress(estimate.site.address)" target='_blank'>
              {{ getFullAddress(estimate.site.address) }}
            </a>
          </b-col>
        </b-row>

        <b-row v-if='estimate.customer_detail.address' class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Billing Addr.</b>
          </b-col>
          <b-col cols='8'>
            <a :href="'http://maps.google.com/?q=' + encodeAddress(estimate.customer_detail.address)" target='_blank'>
              {{ getFullAddress(estimate.customer_detail.address) }}
            </a>
          </b-col>
        </b-row>

        <div class='single-estimate-link-row' v-if="hasPermission('estimates', 'update')">
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
    encodeAddress(address) {
      return encodeURIComponent(this.getFullAddress(address));
    },
    getFullAddress(address) {
      return address != null ? address.full_address : ''
    },
    updateAddress() {
      var params = {
        tree_site: {
          address_attributes: {
            ... this.addresses.siteAddress
          }
        }
      }

      if(this.estimate.site.address){
        params.tree_site.address_attributes.id = this.estimate.site.address.id
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
        customer_detail: {
          address_attributes: {}
        }
      }

      if(!this.estimate.customer.address && !this.addresses.billingAddress) {
        return new Promise((resolve, reject) => { resolve(true) });
      }

      // if(this.estimate.customer.address) {
      //   params.customer.address_attributes.id = this.estimate.customer.address.id
      // }

      if(this.addresses.billingAddress) {
        params.customer_detail.address_attributes = {
          ...this.addresses.billingAddress
        }
      }
      else {
        params.customer.address_attributes._destroy = true
      }

      return this.axiosPut(`/customer_details/${this.estimate.customer_detail.id}`, params).then(response => {
        EventBus.$emit('ESTIMATE_UPDATED', { customer_detail: response.data.customer_detail });
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
