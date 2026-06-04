<template>
  <b-nav-item-dropdown
    id="actions-dropdown"
    right
    no-caret
  >
    <template #button-content>
      <b-icon icon="three-dots" aria-hidden="true"></b-icon>
      <span class="sr-only">Actions</span>
    </template>
    <!-- <b-dropdown-item v-if="!estimate.is_unknown" @click='updateStatus(true)'>
      Move to Unknown
    </b-dropdown-item>

    <b-dropdown-item v-if="estimate.is_unknown || estimate.status == 'cancelled'" @click='updateStatus(false)'>
      Reactivate
    </b-dropdown-item> -->

    <b-dropdown-item @click='triggerAction("no_response_followup")' v-if='estimateHelper.canSendFollowup()'>
      Send Followup
    </b-dropdown-item>

    <b-dropdown-item @click='triggerAction("send_schedule_email")' v-if='estimateHelper.canSendSchedulingEmail()'>
      Send Schedule Email
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

    <b-dropdown-item @click='reopenJob' v-if="estimate.status == 'work_completed'">
      Re-Open Job
    </b-dropdown-item>

    <b-dropdown-item @click='triggerAction("change_status")' v-if="estimate.state != 'completed'">
      Status and Tags
    </b-dropdown-item>

    <!-- <b-dropdown-item v-if='estimate.status != "cancelled"' @click='triggerAction("cancel")'>
      Cancel
    </b-dropdown-item> -->
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
      var params = { estimate: { is_unknown: unknownStatus, cancelled_at: null } };
      this.axiosPut(`/estimates/${this.estimate.id}`, params).then(response => {
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
      });
    },
    triggerAction(name) {
      EventBus.$emit('ESTIMATE_TRIGGER_ACTION', name, this.estimate.id);
    },
    reopenJob() {
      this.axiosPut(`/estimates/${this.estimate.id}`, { estimate: { work_complete: false } }).then(response => {
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
      });
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
    list-style: none;
  }

  /* The dropdown toggle is the ⋯ tap target */
  #actions-dropdown >>> .dropdown-toggle {
    padding: 8px 14px;
    color: var(--main-color);
    font-size: 16px;
    line-height: 1;
    border-radius: 4px;
  }

  #actions-dropdown >>> .dropdown-toggle:hover {
    background-color: #f0e8e8;
  }

  /* Individual action items */
  #actions-dropdown >>> .dropdown-item {
    padding: 6px 12px;
  }
</style>
