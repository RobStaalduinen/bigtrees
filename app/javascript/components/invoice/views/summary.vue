<template>
  <div>
    <app-collapsable id='invoice-collapse'>
      <template v-slot:title>
        <b>Invoice #{{ estimate.invoice.number }}</b>
      </template>

      <template v-slot:content>
        <b-row class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Number</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.invoice.number }}
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Date sent</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.invoice.sent_at }}
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Payment</b>
          </b-col>
          <b-col cols='8'>
            {{ paymentData }}
          </b-col>
        </b-row>

        <div class='single-estimate-link-row'>
          <a :href='`/quotes/receipt?estimate_id=${estimate.id}`' class='single-estimate-link' v-if='estimate.invoice.paid_at != null'>
            Receipt
          </a>

          <a :href='`/invoices/${estimate.invoice.id}/pdf`' class='single-estimate-link'>
            Download
          </a>
          <div class='single-estimate-link' v-b-toggle.invoice-send>
            Resend
          </div>
          <div class='single-estimate-link' v-b-toggle.invoice-edit>
            <b-icon icon='pencil-square' class='app-icon'></b-icon>
          </div>
        </div>
      </template>
    </app-collapsable>

    <app-resend-invoice id='invoice-send' :estimate='estimate'></app-resend-invoice>
    <app-edit-invoice id='invoice-edit' :estimate='estimate'></app-edit-invoice>
  </div>
</template>

<script>
import ResendInvoice from '../actions/resend';
import EditInvoice from '../actions/edit';

export default {
  components: {
    'app-resend-invoice': ResendInvoice,
    'app-edit-invoice': EditInvoice
  },
  props: {
    estimate: {
      required: true,
      type: Object
    }
  },
  computed: {
    paymentData() {
      var invoice = this.estimate.invoice;''
      if(!invoice.paid_at) {
        return 'Not Yet Paid'
      }
      else {
        return `Paid by ${invoice.payment_method} at ${invoice.paid_at}`
      }
    }
  }
}
</script>

<style scoped>

</style>
