<template>
  <component
    v-if='estimate && currentAction()'
    :is='currentAction().inputComponent'
    :estimate='estimate'
    :id='currentAction().inputComponent'
    @changed="(payload) => $emit('changed', payload)"
    @cancelled="cancelled()"
  ></component>
</template>

<script>
import EventBus from '@/store/eventBus'
import SendQuote from '@/components/quote/actions/sendInitial';
import ScheduleWork from '@/components/estimate/actions/schedule';
import SendInvoice from '@/components/invoice/actions/send';
import PayInvoice from '@/components/invoice/actions/pay';
import SendToTeam from '@/components/quote/actions/sendToTeam';

const ACTIONS = {
  'send_quote': {
    actionLabel: 'Send Quote',
    inputComponent: 'estimate-send-quote'
  },
  'schedule_work': {
    actionLabel: 'Schedule Work',
    inputComponent: 'estimate-schedule-work'
  },
  'send_invoice': {
    actionLabel: 'Send Invoice',
    inputComponent: 'estimate-send-invoice'
  },
  'pay_invoice': {
    actionLabel: 'Pay Invoice',
    inputComponent: 'estimate-pay-invoice'
  },
  'send_to_team': {
    actionLabel: 'Send to Team',
    inputComponent: 'estimate-send-to-team'
  }
}

export default {
  components: {
    'estimate-send-quote': SendQuote,
    'estimate-schedule-work': ScheduleWork,
    'estimate-send-invoice': SendInvoice,
    'estimate-pay-invoice': PayInvoice,
    'estimate-send-to-team': SendToTeam
  },
  data() {
    return {
      estimate: null,
      actionName: null
    }
  },
  methods: {
    currentAction() {
      return ACTIONS[this.actionName];
    },
    cancelled() {
      console.log("CANCELLED");
      this.estimate = null;
    }
  },
  mounted() {
    EventBus.$on('ESTIMATE_TRIGGER_ACTION', (action_name, estimate_id) => {
      console.log("TRIGGERING " + action_name + " FOR " + estimate_id);
      this.estimate = this.$store.state.estimates.filter((estimate) => estimate.id == estimate_id)[0];
      this.actionName = action_name;
      this.$nextTick(() => {
        this.$root.$emit('bv::toggle::collapse', this.currentAction().inputComponent);
      })

    });
  }
}
</script>

<style>

</style>
