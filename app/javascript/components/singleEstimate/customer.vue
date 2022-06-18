<template>
  <div>
    <app-collapsable id='customer-collapse'>
      <template v-slot:title>
        <b>Customer:</b> &nbsp; {{ estimate.customer.name }}
      </template>

      <template v-slot:content>
        <b-row class='spaced-row'>
          <b-col cols='3' class='right-column'>
            <b>Name</b>
          </b-col>
          <b-col cols='9'>
            {{ estimate.customer.name }}
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='3' class='right-column'>
            <b>Email</b>
          </b-col>
          <b-col cols='9'>
            <div style='overflow-x: scroll'>
              <a :href='"mailto:" + estimate.customer.email'>{{ estimate.customer.email }}</a>
            </div>
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='3' class='right-column'>
            <b>Phone</b>
          </b-col>
          <b-col cols='9'>
            <div style='overflow-x: scroll'>
              <a :href='"tel:" + estimate.customer.phone'>{{ estimate.customer.phone }}</a>
            </div>
          </b-col>
        </b-row>

        <div class='single-estimate-link-row'>
          <router-link :to='"/admin/estimates/new?customer_id=" + estimate.customer.id' class='single-estimate-link'>New Estimate</router-link>
          <div class='single-estimate-link' v-b-toggle.customer-edit>
            <b-icon icon='pencil-square' class='app-icon'></b-icon>
          </div>
        </div>

      </template>
    </app-collapsable>

    <app-right-sidebar id='customer-edit' title='Edit Customer' submitText='Save' :onSubmit='updateCustomer'>
      <template v-slot:content>
        <app-customer-form v-model='customer'> </app-customer-form>
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
    }
  },
  data() {
    return {
      customer: this.estimate.customer
    }
  },
  methods: {
    updateCustomer() {
      var params = { customer: this.customer }
      this.axiosPut(`/customers/${this.customer.id}`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', 'customer-edit');
        EventBus.$emit('ESTIMATE_UPDATED', { customer: response.data.customer });
      });
    }
  }
}
</script>

<style scoped>
</style>
