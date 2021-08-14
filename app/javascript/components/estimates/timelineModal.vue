<template>
    <b-modal :id='modalId' centered title='Timeline'>
      <div id='timeline-container'>

        <div class='timeline-row' v-if='estimate.created_at != null'>
          <b>Requested</b>
          {{ localizeDate(estimate.created_at) }}
        </div>

        <div class='timeline-row' v-if='estimate.quote_sent_date != null'>
          <b>Quote Sent</b>
          {{ localizeDate(estimate.quote_sent_date) }}
        </div>

        <div class='timeline-row' v-if='estimate.work_start_date != null'>
          <b>Scheduled</b>
          {{ estimate.work_start_date | localizeDate }} - {{ estimate.work_end_date | localizeDate }}
        </div>

        <div class='timeline-row' v-if='estimate.invoice.sent_at != null'>
          <b>Invoice Sent</b>
          {{ localizeDate(estimate.invoice.sent_at) }}
        </div>

        <div class='timeline-row' v-if='estimate.invoice.paid_at != null'>
          <b>Paid</b>
          {{ localizeDate(estimate.invoice.paid_at) }}
        </div>

      </div>
      <template v-slot:modal-footer>
        <b-button block class='submit-button' @click='close()'>Done</b-button>
      </template>
    </b-modal>
</template>

<script>
import moment from 'moment'
export default {
  props: {
    estimate: {
      type: Object,
      required: true
    },
    modalId: {
      type: String,
      required: true
    }
  },
  methods: {
    localizeDate(date){
      return moment(date).format('MMMM Do YYYY');
    },
    close(){
      this.$bvModal.hide(this.modalId);
    }
  }
}
</script>

<style scoped>
  #timeline-container {
    display: flex;
    flex-direction: column;
  }

  .timeline-row{
    display: flex;
    flex-direction: column;
    margin-bottom: 16px;
  }
</style>
