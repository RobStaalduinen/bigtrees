<template>
  <app-scrollable-sidebar :id='id' title='State' submitText='Save' :onSubmit='handleSubmit'>
    <template v-slot:content>
      <app-select-field v-model='state' :options='options' label='State' name='state'/>

      <app-input-field v-model='reason' name='reason' label='Reason (optional)' v-if='reasonAllowed()'/>
    </template>
  </app-scrollable-sidebar>
</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  props: {
    id: { required: true },
    estimate: { required: true },
    // Restrict the selectable states; defaults to the full set so the
    // quote-page header keeps every option.
    states: {
      type: Array,
      default: () => ['in_progress', 'on_hold', 'unknown', 'done', 'cancelled']
    }
  },
  data() {
    return {
      state: this.estimate.state,
      reason: this.estimate.state_reason
    }
  },
  computed: {
    options() {
      return this.states.map(option => ({
        value: option,
        text: option.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase())
      }));
    }
  },
  methods: {
    reasonAllowed() {
      return ['on_hold', 'unknown', 'cancelled'].includes(this.state);
    },
    handleSubmit() {
      if (!this.reasonAllowed()) {
        this.reason = null;
      }

      const params = { estimate: { state: this.state, state_reason: this.reason } };

      this.axiosPut(`/estimates/${this.estimate.id}`, params)
        .then(response => {
          if (response.status === 200) {
            this.$root.$emit('bv::toggle::collapse', this.id);
            EventBus.$emit('ESTIMATE_UPDATED', { state: this.state, state_reason: this.reason });
          }
        });
    }
  },
  watch: {
    'estimate.state'(newVal) {
      this.state = newVal;
    },
    'estimate.state_reason'(newVal) {
      this.reason = newVal;
    }
  }
}
</script>
