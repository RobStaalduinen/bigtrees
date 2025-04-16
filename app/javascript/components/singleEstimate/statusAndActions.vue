<template>
  <div id='status-action-container'>
    <div id='current-status'>
      <b>Current Status: </b> &nbsp;<i>{{ estimate.formatted_status }} {{ estimate.is_unknown ? '(Unknown)' : '' }}</i>
    </div>

    <div class='single-estimate-link-row'>
      <estimate-actions-list
        v-if="hasPermission('estimates', 'update')"
        :estimate='estimate'
      ></estimate-actions-list>

      <div class='single-estimate-link' @click='toggleImages' v-if='hasImages()'>
        Images
      </div>
      <div class='single-estimate-link' @click='toggleAction' v-if="hasPermission('estimates', 'update') && currentAction">
        <b>{{ `Next: ${currentAction.actionLabel}` }}</b>
      </div>
    </div>

    <component
      v-if="hasPermission('estimates', 'update') && currentAction"
      :is='currentAction.inputComponent'
      :estimate='estimate'
      :id='currentAction.inputComponent'
    ></component>

    <estimate-action-handler
      :estimate='estimate'
    ></estimate-action-handler>
  </div>
</template>

<script>
import ScheduleWork from '../estimate/actions/schedule';
import Approve from '../estimate/actions/approve';
import StartJob from '@/components/job/actions/start';
import CompleteJob from '@/components/job/actions/complete';
import SendInvoice from '../invoice/actions/send';
import PayInvoice from '../invoice/actions/pay';
import AddCosts from '../costs/actions/createMultiple';
import SendQuote from '../quote/actions/sendInitial';
import ActionList from '@/components/estimates/actionsList';
import ListActionHandler from '@/components/estimate/utils/listActionHandler';
import { invoiceSent } from '@/components/estimate/utils/stateTransitions.js';

import EventBus from '@/store/eventBus'

const STEPS = {
  'needs_costs': {
    actionLabel: 'Add Costs',
    inputComponent: 'estimate-add-costs',
  },
  'pending_quote': {
    actionLabel: 'Send Quote',
    inputComponent: 'estimate-send-quote',
  },
  'quote_sent': {
    actionLabel: 'Approve',
    inputComponent: 'estimate-approve'
  },
  'approved': {
    actionLabel: 'Schedule',
    inputComponent: 'estimate-schedule-quote'
  },
  'pending_permit': {
    actionLabel: 'Schedule',
    inputComponent: 'estimate-schedule-quote'
  },
  'work_scheduled': {
    actionLabel: 'Start Job',
    inputComponent: 'estimate-start-job'
  },
  'work_started': {
    actionLabel: 'Complete Job',
    inputComponent: 'estimate-complete-job'
  },
  'work_completed': {
    actionLabel: 'Send Invoice',
    inputComponent: 'estimate-send-invoice'
  },
  'final_invoice_sent': {
    actionLabel: 'Process Payment',
    inputComponent: 'estimate-pay-invoice'
  }
}

export default {
  components: {
    'estimate-schedule-quote': ScheduleWork,
    'estimate-send-quote': SendQuote,
    'estimate-send-invoice': SendInvoice,
    'estimate-pay-invoice': PayInvoice,
    'estimate-add-costs': AddCosts,
    'estimate-actions-list': ActionList,
    'estimate-action-handler': ListActionHandler,
    'estimate-approve': Approve,
    'estimate-start-job': StartJob,
    'estimate-complete-job': CompleteJob,
  },
  props: {
    estimate: {
      required: true
    }
  },
  computed: {
    currentAction() {
      return STEPS[this.estimate.status];
    }
  },
  methods: {
    toggleImages() {
      EventBus.$emit('TOGGLE_IMAGE_GALLERY', { estimate_id: this.estimate.id });
    },
    toggleAction() {
      this.$root.$emit('bv::toggle::collapse', this.currentAction.inputComponent);
    },
    hasImages() {
      return this.estimate.tree_images.length > 0
      // return this.estimate.tree_images.map(tree_image => {
      //   return tree.tree_images.length > 0
      // }).some(img => img === true);
    }
  }
}
</script>

<style>
  #status-action-container {
    border-width: 2px 0 0 0;
    border-color: var(--main-color);
    border-style: solid;
    width: 100%;
    background-color: white;

    display: flex;
    flex-direction: column;
  }

  #current-status {
    width: 100%;
    display: flex;
    justify-content: center;
    padding: 4px;
  }
</style>
