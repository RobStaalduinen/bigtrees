<template>
  <div id='status-action-container'>
    <div id='current-status'>
      <b>Current Status: </b> &nbsp;<i>{{ estimate.formatted_status }} {{ estimate.is_unknown ? '(Unknown)' : '' }}</i>
    </div>

    <div class='single-estimate-link-row'>
      <estimate-actions-list
        :estimate='estimate'
        @changed="(payload) => $emit('changed', payload)"
      ></estimate-actions-list>

      <div class='single-estimate-link' @click='toggleImages'>
        View Images
      </div>
      <div class='single-estimate-link' v-b-toggle.input-action v-if='currentAction'>
        <b>{{ `Next: ${currentAction.actionLabel}` }}</b>
      </div>
    </div>

    <component
      v-if='currentAction'
      :is='currentAction.inputComponent'
      :estimate='estimate'
      id='input-action'
      @changed="(payload) => $emit('changed', payload)"
    ></component>
  </div>
</template>

<script>
import ScheduleWork from '../estimate/actions/schedule';
import SendInvoice from '../invoice/actions/send';
import PayInvoice from '../invoice/actions/pay';
import AddCosts from '../costs/actions/createMultiple';
import SendQuote from '../quote/actions/sendInitial';
import ActionList from '@/components/estimates/actionsList';
import { invoiceSent } from '@/components/estimate/utils/stateTransitions.js';

import EventBus from '@/store/eventBus'

const STEPS = {
  'needs_costs': {
    actionLabel: 'Add Costs',
    inputComponent: 'estimate-add-costs'
  },
  'pending_quote': {
    actionLabel: 'Send Quote',
    inputComponent: 'estimate-send-quote',
  },
  'quote_sent': {
    actionLabel: 'Schedule',
    inputComponent: 'estimate-schedule-quote'
  },
  'work_scheduled': {
    actionLabel: 'Send Invoice',
    inputComponent: 'estimate-send-invoice',
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
    'estimate-actions-list': ActionList
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
      EventBus.$emit('TOGGLE_IMAGE_GALLERY', {});
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
