<template>
  <div>
    <app-collapsable :title='"Customer: " + estimate.customer.name' id='customer-collapse'>
      <template v-slot:content>
        <div class='customer-header-row'>
          Details
          <b-icon icon='pencil-square' class='edit-icon' v-b-toggle.customer-edit></b-icon>
        </div>
        <div class='customer-row'>
          <div class='customer-row-left'>
            Name
          </div>
          <div class='customer-row-right'>
            {{ estimate.customer.name }}
          </div>
        </div>

        <div class='customer-row'>
          <div class='customer-row-left'>
            Email
          </div>
          <div class='customer-row-right'>
            <a :href='"mailto:" + estimate.customer.email'>{{ estimate.customer.email }}</a>
          </div>
        </div>

        <div class='customer-row'>
          <div class='customer-row-left'>
            Phone
          </div>
          <div class='customer-row-right'>
            <a :href='"tel:" + estimate.customer.phone'>{{ estimate.customer.phone }}</a>
          </div>
        </div>

        <div class='customer-row'>
          <div class='customer-row-left'>
            Billing Add.
          </div>
          <div class='customer-row-right'>
            {{ estimate.customer.address != null ? estimate.customer.address.full_address : 'None' }}
          </div>
        </div>

        <div class='customer-link-row'>
          <router-link :to='"/admin/estimates/new?customer_id=" + estimate.customer.id' class='customer-link'>New Estimate</router-link>
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
        this.$emit('changed', { customer: response.data.customer });
      });
    }
  }
}
</script>

<style scoped>
  .customer-header-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px;
    font-weight: 600;

    border-style: solid;
    border-color: var(--main-color);
    border-width: 0 0 1px 0;
  }

  .edit-icon {
    color: var(--main-color);
  }

  .customer-row {
    display: flex;
    margin-top: 8px;
    padding: 0 8px;
  }

  .customer-row-left {
    width: 15%;
    text-align: right;
    font-weight: 600;
    margin-right: 16px
  }

  .customer-row-right {
    width: 85%;
  }

  .customer-link-row{
    display: flex;
    justify-content: flex-end;
    border-style: solid;
    border-width: 1px 0 0 0;
    border-color: lightgray;
    margin-top: 8px;
  }

  .customer-link {
    padding: 6px 12px;

    border-width: 0 0 0 1px;
    border-color: lightgray;
    border-style: solid;
  }
</style>
