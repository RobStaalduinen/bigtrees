<template>
  <div>
    <app-collapsable id='quote-collapse'>
      <template v-slot:title>
        <b>Quote</b> &nbsp; {{ '- ' + quoteStatus() }}
      </template>

      <template v-slot:content>
        <b-row class='spaced-row' v-if='estimate.quote_sent_date'>
          <b-col cols='4' class='right-column'>
            <b>Sent At</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.quote_sent_date }}
          </b-col>
        </b-row>

        <b-row class='spaced-row' v-if='estimate.work_start_date'>
          <b-col cols='4' class='right-column'>
            <b>Work Date</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.work_start_date | localizeDate }} - {{ estimate.work_end_date | localizeDate }}
          </b-col>
        </b-row>

        <div class='single-estimate-link-row'>
          <a class='single-estimate-link' :href='`/estimates/${estimate.id}/quotes.pdf`'>
            Download
          </a>
          <div class='single-estimate-link' v-b-toggle.quote-send-team>
            Send to Team
          </div>
          <div class='single-estimate-link' v-b-toggle.quote-send>
            Resend
          </div>
        </div>

      </template>
    </app-collapsable>

    <app-quote-send id='quote-send' :estimate='estimate'></app-quote-send>
    <app-quote-send-team id='quote-send-team' :estimate='estimate'></app-quote-send-team>
  </div>
</template>

<script>
import QuoteSend from '../actions/sendInitial';
import QuoteSendTeam from '../actions/sendToTeam';

export default {
  components: {
    'app-quote-send': QuoteSend,
    'app-quote-send-team': QuoteSendTeam
  },
  props: {
    estimate: {
      required: true
    }
  },
  methods: {
    quoteStatus() {
      if(this.estimate.work_start_date) {
        return 'Accepted'
      }
      else if(this.estimate.quote_sent_date) {
        return 'Sent'
      }
      else {
        return 'Not Yet Sent'
      }
    }
  }
}
</script>

<style scoped>

</style>
