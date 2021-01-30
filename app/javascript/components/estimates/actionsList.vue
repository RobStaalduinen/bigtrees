<template>
  <b-nav-item-dropdown
    id="actions-dropdown"
    text="Actions"
    right
  >
    <!-- <b-dropdown-item v-if="!estimate.is_unknown" :href='`/estimates/${estimate.id}/quote_mailouts/new?mail_type=followup`'>
      Send Followup
    </b-dropdown-item> -->

    <b-dropdown-item v-if="!estimate.is_unknown" @click='updateStatus(true)'>
      Move to Unknown
    </b-dropdown-item>

    <b-dropdown-item v-if="estimate.is_unknown" @click='updateStatus(false)'>
      Reactivate
    </b-dropdown-item>

    <template v-if="!statusOnly">
      <b-dropdown-item @click='triggerAction("send_quote")' v-if='estimateHelper.canSendQuote()'>
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
      </b-dropdown-item>

      <b-dropdown-item @click='triggerAction("send_to_team")'>
        Send to Team
      </b-dropdown-item>
    </template>
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
    },
    statusOnly: {
      type: Boolean,
      default: false
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
      EventBus.$emit('ESTIMATE_TRIGGER_ACTION', name, this.estimate.id);
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
