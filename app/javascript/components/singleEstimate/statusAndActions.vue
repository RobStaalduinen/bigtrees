<template>
  <div id='status-action-container'>
    <div id='current-status'>
      <b>Current Status: </b> &nbsp;<i>{{ estimate.formatted_status }} {{ estimate.is_unknown ? '(Unknown)' : '' }}</i>
    </div>

    <div class='single-estimate-link-row'>
      <div class='single-estimate-link' @click='toggleImages'>
        View Images
      </div>
      <div id='next-label' v-if='currentAction'>
        <b>Next Step:</b>
      </div>
      <div class='single-estimate-link' v-b-toggle.input-action v-if='currentAction'>
        {{ currentAction.actionLabel }}
      </div>
    </div>

    <component v-if='currentAction' :is='currentAction.inputComponent' :estimate='estimate' id='input-action' @changed="(payload) => $emit('changed', payload)"></component>
  </div>
</template>

<script>
import ScheduleWork from '../estimate/actions/schedule';
import SendInvoice from '../invoice/actions/send';
import PayInvoice from '../invoice/actions/pay';
import { invoiceSent } from '@/components/estimate/utils/stateTransitions.js';

import EventBus from '@/store/eventBus'

const STEPS = {
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
    'estimate-send-invoice': SendInvoice,
    'estimate-pay-invoice': PayInvoice
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
      EventBus.$emit('TOGGLE_IMAGE_GALLERY', null);
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

  #next-label {
    padding: 6px 12px;
  }
</style>
