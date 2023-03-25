<template>
  <div>
    <app-collapsable :id='collapsableName'>
      <template v-slot:title>
        <b>{{ isParentCustomer ? 'Parent Customer:' : 'Display Customer:' }}</b> &nbsp; {{ customerDetails.name }}
      </template>

      <template v-slot:content>
        <b-row class='spaced-row'>
          <b-col cols='3' class='right-column'>
            <b>Name</b>
          </b-col>
          <b-col cols='9'>
            {{ customerDetails.name }}
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='3' class='right-column'>
            <b>Email</b>
          </b-col>
          <b-col cols='9'>
            <div style='overflow-x: scroll'>
              <a :href='"mailto:" + customerDetails.email'>{{ customerDetails.email }}</a>
            </div>
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='3' class='right-column'>
            <b>Phone</b>
          </b-col>
          <b-col cols='9'>
            <div style='overflow-x: scroll'>
              <a :href='"tel:" + customerDetails.phone'>{{ customerDetails.phone }}</a>
            </div>
          </b-col>
        </b-row>

        <div class='single-estimate-link-row'>
          <router-link :to='"/admin/estimates/new?customer_id=" + estimate.customer.id' class='single-estimate-link' v-if='isParentCustomer'>New Estimate</router-link>

          <div class='single-estimate-link' v-b-toggle='collapsableName + "-edit"'>
            <b-icon icon='pencil-square' class='app-icon'></b-icon>
          </div>
        </div>

      </template>
    </app-collapsable>

    <app-right-sidebar :id='collapsableName + "-edit"' title='Edit Customer' submitText='Save' :onSubmit='updateCustomer'>
      <template v-slot:content>
        <app-customer-form v-model='customerDetails'> </app-customer-form>

        <b-form-group label="Update Display Customer" v-if='isParentCustomer'>
          <b-form-checkbox
            id="update-display"
            v-model="shouldUpdateDisplayCustomer"
            name="update-display"
            :value='true'
            :unchecked-value='false'
          />
        </b-form-group>
      </template>
    </app-right-sidebar>
  </div>
</template>

<script>
import CustomerForm from '../createEstimate/customerForm';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-customer-form': CustomerForm
  },
  props: {
    estimate: {
      required: true
    },
    isParentCustomer: {
      default: false
    }
  },
  data() {
    return {
      customerDetails: this.customer(),
      shouldUpdateDisplayCustomer: false
    }
  },
  computed: {
    collapsableName() {
      return this.isParentCustomer ? 'parent-customer-collapse' : 'customer-collapse'
    }
  },
  methods: {
    customer() {
      return this.isParentCustomer ? this.estimate.customer : this.estimate.customer_detail
    },
    updateCustomer() {
      if(this.isParentCustomer) {
        var params = { customer: this.customerDetails }
        this.axiosPut(`/customers/${this.estimate.customer.id}`, params).then(response => {
          EventBus.$emit('ESTIMATE_UPDATED', { customer: response.data.customer });

          if(this.shouldUpdateDisplayCustomer) {
            this.updateDisplayCustomer().then(response => {
              this.$root.$emit('bv::toggle::collapse', this.collapsableName + '-edit');
            })
          }
          else {
            this.$root.$emit('bv::toggle::collapse', this.collapsableName + '-edit');
          }
        });
      }
      else {
        this.updateDisplayCustomer().then(response => {
          this.$root.$emit('bv::toggle::collapse', this.collapsableName + '-edit');
        })
      }
    },
    updateDisplayCustomer() {
      var params = { customer_detail: this.customerDetails }
      return this.axiosPut(`/customer_details/${this.estimate.customer_detail.id}`, params).then(response => {
        EventBus.$emit('ESTIMATE_UPDATED', { customer_detail: response.data.customer_detail });
      });
    }
  },
  watch: {
    estimate() {
      this.customerDetails = this.customer();
    }
  }
}
</script>

<style scoped>
</style>
