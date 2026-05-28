<template>
  <div>
    <app-collapsable :id='collapsableName'>
      <template v-slot:title>
        <b>{{ isParentCustomer ? 'Parent Customer:' : 'Display Customer:' }}</b> &nbsp; {{ customerDetails.name }}
        <span v-if='isParentCustomer && customerDetails.priority' class='priority-badge' :class='priorityBadgeClass'>Prio {{ customerDetails.priority }}</span>
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

        <div class='single-estimate-link-row' v-if="hasPermission('estimates', 'update')">
          <router-link :to='"/admin/estimates/new?customer_id=" + estimate.customer.id' class='single-estimate-link' v-if="isParentCustomer">New Estimate</router-link>

          <div class='single-estimate-link' v-b-toggle='collapsableName + "-edit"'>
            <b-icon icon='pencil-square' class='app-icon'></b-icon>
          </div>
        </div>

      </template>
    </app-collapsable>

    <app-right-sidebar :id='collapsableName + "-edit"' title='Edit Customer' submitText='Save' :onSubmit='updateCustomer'>
      <template v-slot:content>
        <app-customer-form v-model='customerDetails' :showPriority='isParentCustomer'> </app-customer-form>

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
    },
    priorityBadgeClass() {
      return `priority-badge-${this.customerDetails.priority}`
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
  .priority-badge {
    display: inline-block;
    margin-left: 8px;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 0.75em;
    font-weight: 700;
    color: #3a2e15;
    border: 1px solid rgba(0, 0, 0, 0.15);
  }

  .priority-badge-1 {
    background: linear-gradient(135deg, #ffe066 0%, #d4af37 100%);
  }

  .priority-badge-2 {
    background: linear-gradient(135deg, #f5e7a8 0%, #e0c46c 100%);
  }

  .priority-badge-3 {
    background: linear-gradient(135deg, #e8e8e8 0%, #b8b8b8 100%);
  }

  .priority-badge-4 {
    background: linear-gradient(135deg, #dcae84 0%, #b8763e 100%);
    color: #2e1a0a;
  }

  .priority-badge-5 {
    background: linear-gradient(135deg, #c68a52 0%, #8b4e1f 100%);
    color: #ffffff;
  }
</style>
