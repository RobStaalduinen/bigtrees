<template>
  <app-right-sidebar :id='id' title='Send Invoice' submitText='Send' :onSubmit='sendInvoice' :alternateAction='skipSend'>
    <template v-slot:content>
      <app-input-field
        v-model='invoiceNumber'
        name='number'
        label='Invoice Number'
        validationRules='required'
      >

      </app-input-field>
      <app-email-form :value='emailDefinition' @changed='payload => handleChange(payload)'></app-email-form>
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/email';
import { invoiceContent } from '../../../content/emailContent';
import { invoiceSent } from '@/components/estimate/utils/stateTransitions';

export default {
  components: {
    'app-email-form': EmailForm
  },
  props: {
    id: {
      required: true
    },
    estimate: {
      required: true
    }
  },
  data() {
    return {
      emailDefinition: {
        email: this.estimate.customer.email,
        content: invoiceContent,
        subject: 'Big Tree Services Final Invoice'
      },
      invoiceNumber: null
    }
  },
  methods: {
    handleChange(new_email) {
      this.emailDefinition = { ...new_email }
    },
    sendInvoice() {
      var params = {
        invoice: { number: this.invoiceNumber },
        dest_email: this.emailDefinition.email,
        content: this.emailDefinition.content,
        subject: this.emailDefinition.subject
      }

      invoiceSent(this.estimate, params).then(response => {
        this.$emit('changed', response.data);
        this.$root.$emit('bv::toggle::collapse', this.id);
      })
    },
    skipSend() {
      var params = { invoice: {}, skip_mail: true }
      invoiceSent(this.estimate, params).then(response => {
        this.$emit('changed', response.data);
        this.$root.$emit('bv::toggle::collapse', this.id);
      })
    }
  },
  mounted() {
    this.axiosGet(`/invoices/${this.estimate.invoice.id}`).then(response => {
      this.invoiceNumber = response.data.invoice.potential_number;
    })
  }
}
</script>

<style scoped>

</style>
