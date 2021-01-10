<template>
  <div>
    <app-collapsable id='timeline-collapse'>
      <template v-slot:title>
        <b>Timeline</b> &nbsp; - {{ topMessage() }}
      </template>

      <template v-slot:content>
        <b-row class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Requested</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.created_at | localizeDate }}
          </b-col>
        </b-row>

        <b-row class='spaced-row' v-if='estimate.quote_sent_date'>
          <b-col cols='4' class='right-column'>
            <b>Quote Sent</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.quote_sent_date | localizeDate }}
          </b-col>
        </b-row>

        <b-row class='spaced-row' v-if='estimate.work_date'>
          <b-col cols='4' class='right-column'>
            <b>Scheduled</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.work_date | localizeDate }}
            <b-icon icon='pencil-square' class='app-icon' v-b-toggle.timeline-schedule-work></b-icon>
          </b-col>
        </b-row>

        <b-row class='spaced-row' v-if='estimate.invoice.sent_at'>
          <b-col cols='4' class='right-column'>
            <b>Invoice Sent</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.invoice.sent_at | localizeDate }}
          </b-col>
        </b-row>

        <b-row class='spaced-row' v-if='estimate.invoice.paid_at'>
          <b-col cols='4' class='right-column'>
            <b>Paid</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.invoice.paid_at | localizeDate }}
          </b-col>
        </b-row>
      </template>
    </app-collapsable>

    <estimate-schedule-work id='timeline-schedule-work' :estimate='estimate' @changed='(payload) => $emit("changed", payload)'></estimate-schedule-work>
  </div>
</template>

<script>
import ScheduleWork from '@/components/estimate/actions/schedule';

export default {
  components: {
    'estimate-schedule-work': ScheduleWork
  },
  props: {
    estimate: {
      required: true
    }
  },
  methods: {
    topMessage() {
      var estimate = this.estimate;
      var localizeDate = this.$options.filters.localizeDate;

      if(estimate.invoice.paid_at != null) {
        return `Paid: ${localizeDate(estimate.invoice.paid_at)}`
      }
      else if(estimate.invoice.send_at != null) {
        return `Invoice Sent: ${localizeDate(estimate.invoice.send_at)}`
      }
      else if(estimate.work_date != null) {
        return `Scheduled: ${localizeDate(estimate.invoice.work_date)}`
      }
      else if(estimate.quote_sent_date != null) {
        return `Quote Sent: ${localizeDate(estimate.quote_sent_date)}`
      }
      else {
        return `Requested: ${localizeDate(estimate.created_at)}`
      }
    }
  }
}
</script>

<style>

</style>
