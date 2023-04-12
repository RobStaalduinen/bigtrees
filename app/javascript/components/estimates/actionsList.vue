<template>
  <b-nav-item-dropdown
    id="actions-dropdown"
    text="Actions"
    right
  >
    <b-dropdown-item v-if="!estimate.is_unknown" @click='updateStatus(true)'>
      Move to Unknown
    </b-dropdown-item>

    <b-dropdown-item v-if="estimate.is_unknown" @click='updateStatus(false)'>
      Reactivate
    </b-dropdown-item>

    <b-dropdown-item @click='triggerAction("no_response_followup")' v-if='estimateHelper.canSendFollowup()'>
      Send Followup
    </b-dropdown-item>

    <!-- <b-dropdown-item @click='triggerAction("send_quote")' v-if='estimateHelper.canSendQuote()'>
      Send Quote
    </b-dropdown-item>

    <b-dropdown-item @click='triggerAction("schedule_work")' v-if='estimateHelper.canSchedule()'>
      Schedule Work
    </b-dropdown-item>

    <b-dropdown-item @click='triggerAction("send_invoice")' v-if='estimateHelper.canSendInvoice()'>
      Send Invoice
    </b-dropdown-item>

    <b-dropdown-item @click='triggerAction("pay_invoice")' v-if='estimateHelper.canPayInvoice()'>
      Pay Invoice
    </b-dropdown-item> -->

    <b-dropdown-item @click='triggerAction("send_to_team")'>
      Send to Team
    </b-dropdown-item>

    <b-dropdown-item @click='triggerAction("cancel")'>
      Cancel
    </b-dropdown-item>
  </b-nav-item-dropdown>
</template>

<script>
import EventBus from '@/store/eventBus'
import { EstimateHelper } from '@/components/estimate/utils/estimateHelper';

export default {
  props: {
    estimate: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      estimateHelper: new EstimateHelper(this.estimate)
    }
  },
  methods: {
    updateStatus(unknownStatus) {
      var params = { estimate: { is_unknown: unknownStatus } };
      this.axiosPut(`/estimates/${this.estimate.id}`, params).then(response => {
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
      });
    },
    triggerAction(name) {
      if(name == 'cancel') {
        confirm(`Are you sure you want to cancel the estimate for ${this.estimate.customer.name}?`);
        this.axiosPost(`/estimates/${this.estimate.id}/cancel`).then(response => {
          EventBus.$emit('ESTIMATE_UPDATED', {});
        });
      } else {
        EventBus.$emit('ESTIMATE_TRIGGER_ACTION', name, this.estimate.id);
      }
    }
  },
  watch: {
    estimate() {
      this.estimateHelper = new EstimateHelper(this.estimate)
    }
  }
}
</script>

<style scoped>
  #actions-dropdown {
    display: block;
  }

  #actions-dropdown >>> a {
    padding: 6px 12px;
  }
</style>
