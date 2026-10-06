<!--
  Uses app-right-sidebar-form, NOT app-scrollable-sidebar: the scrollable
  variant puts `overflow: scroll` on its content area, which clips the
  datepicker's dropdown calendar to a sliver. Every other datepicker sidebar in
  the app (schedule, job start/complete, invoice send) uses a non-scrolling
  wrapper for the same reason.
-->
<template>
  <app-right-sidebar-form
    :id='id'
    title='Quote Valid Until'
    submitText='Save'
    :onSubmit='save'
    :submitting='submitting'
    @cancelled='reset'
  >
    <template v-slot:content>
      <app-datepicker
        v-model='validUntil'
        label='Valid until'
        name='quote_valid_until'
      ></app-datepicker>

      <div class='hint'>
        Optional. When set, it appears on the quote PDF beside the date tendered.
      </div>

      <div class='clear-row' v-if='validUntil' @click='validUntil = null'>
        <b-icon icon='x-circle' class='app-icon'></b-icon>
        <span class='clear-label'>Clear the date</span>
      </div>
    </template>
  </app-right-sidebar-form>
</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  props: {
    id: { required: true },
    estimate: { required: true }
  },
  data() {
    return {
      validUntil: this.estimate.quote_valid_until || null,
      submitting: false
    }
  },
  methods: {
    save() {
      if(this.submitting) { return; }
      this.submitting = true;

      // Empty string rather than null — Rails casts '' to nil for a date
      // column, whereas a null in JSON is dropped by the params permit.
      const params = { estimate: { quote_valid_until: this.validUntil || '' } };

      this.axiosPut(`/estimates/${this.estimate.id}`, params).then(response => {
        this.submitting = false;
        this.$root.$emit('bv::toggle::collapse', this.id);
        // Pass the serialized estimate straight through — singleEstimate's
        // handler only acts on payloads shaped { estimate: ... }.
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
      }).catch(() => {
        this.submitting = false;
      })
    },
    reset() {
      this.validUntil = this.estimate.quote_valid_until || null;
    }
  },
  watch: {
    'estimate.quote_valid_until'() {
      this.reset();
    }
  }
}
</script>

<style scoped>
  .hint {
    font-size: 12px;
    color: gray;
    margin-top: -8px;
  }

  .clear-row {
    display: flex;
    align-items: center;
    cursor: pointer;
    font-size: 13px;
    color: var(--main-color);
    margin-top: 16px;
  }

  .clear-label {
    margin-left: 6px;
  }
</style>
