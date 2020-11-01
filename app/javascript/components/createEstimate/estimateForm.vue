<template>
  <validation-observer ref="observer">
    <b-form @submit.prevent="onSubmit">
      <estimate-form-section header='Customer'>
        <app-customer-form v-model='customer'> </app-customer-form>
      </estimate-form-section>

      <estimate-form-section header='Address'>
        <app-address-form 
          v-model='addresses'
          :initialSite='initialAddresses.site'
          :initialBilling='initialAddresses.billing'
          @addressesChanged='(payload) => { addresses = payload }'
        >
        </app-address-form>
      </estimate-form-section>

      <estimate-form-section header='Site Details'>
        <estimate-site-questions v-model='site'></estimate-site-questions>
      </estimate-form-section>

      <estimate-form-section header='Images'>
        <estimate-image-form v-model='treeImages'></estimate-image-form>
      </estimate-form-section>

      <estimate-form-section header='Costs'>
        <estimate-cost-form v-model='costs'></estimate-cost-form>
      </estimate-form-section>


      <span id='submit-error' v-if='validationErrors'>{{ validationErrorMessage }}</span>
      <b-button type='submit' block class='submit-button'>Submit</b-button>
    </b-form>
  </validation-observer>
</template>

<script>
import CustomerForm from './customerForm';
import AddressForm from './addressForm';
import SiteQuestions from './siteQuestions';
import ImageForm from './imageForm';
import CostForm from './costsForm';
import FormSection from './formSection'

export default {
  components: {
    'app-customer-form': CustomerForm,
    'app-address-form': AddressForm,
    'estimate-site-questions': SiteQuestions,
    'estimate-image-form': ImageForm,
    'estimate-cost-form': CostForm,
    'estimate-form-section': FormSection
  },
  data() {
    return {
      customer: {},
      addresses: {},
      site: {},
      costs: [],
      treeImages: [],
      validationErrors: false,
      customerId: null,
      siteId: null,
      estimateId: null,
      validationErrorMessage: 'Please check all fields and try again',
      initialAddresses: { site: null, billing: null},
    }
  },
  watch: {
    treeImages: function() {
      console.log("TREES");
      console.log(this.treeImages);
    },
    customer: function() { 
      console.log(this.customer)
    }
  },
  methods: {
    onSubmit() {
      this.validationErrors = false;
      this.$refs.observer.validate().then(success => {
        if (!success) {
          this.validationErrorMessage = 'Please check all fields and try again'
          this.validationErrors = true;
          return;
        }
        var allUploadsComplete = this.treeImages.every(tree => { return tree.uploadCompleted == true })
        if(!allUploadsComplete) {
            this.validationErrorMessage = 'Wait for image uploads to finish and try again'
            this.validationErrors = true;
            return;
        }

        this.submitForm();
      })
    },
    submitForm() {
      let customerAttributes = { ...this.customer }
      if(this.addresses.billingAddress != null) {
        customerAttributes.address_attributes = this.addresses.billingAddress
      }

      let siteAttributes = { ...this.site }
      siteAttributes.address_attributes = this.addresses.siteAddress
      let options = {
        customer: customerAttributes,
        site: siteAttributes,
        estimate: { tree_quantity: 1, requested: true }
      }

      this.axiosPost('/requests', options).then(response => {
        var estimateId = response.data.estimate_id
        let costOptions = {
          costs: this.costs
        }
        this.axiosPost(`/estimates/${estimateId}/costs`, costOptions).then(response => {
          var imageOptions = {
            estimate_id: estimateId,
            images: this.treeImages.map(image => { return image.url } )
          }

          this.axiosPost('/tree_images/create_from_urls', imageOptions).then(response => {
            window.location.href = `/estimates/${estimateId}`
          })
        })
      })
    }
  },
  mounted() {
    var query = this.$route.query;
    if(query.customer_id) {
      this.axiosGet(`/customers/${query.customer_id}`).then(response => {
        if(response.data.id == query.customer_id) {
          var customer = response.data;
          this.customer = {
            id: customer.id,
            name: customer.name,
            email: customer.email,
            phone: customer.phone
          }

          var addresses = {}
          if(customer.address) { 
            addresses.billing = { ...customer.address };
          }

          if(customer.site_address) {
            addresses.site = { ...customer.site_address }
          }

          this.initialAddresses = addresses;
        }
      })
    }
  }
  
}
</script>

<style scoped>
  #submit-error {
    color: #dc3545;
    font-size: 80%;
  }
</style>
