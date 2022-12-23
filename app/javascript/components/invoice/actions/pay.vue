<template>
  <app-right-sidebar :id='id' title='Process Payment' submitText='Save' :onSubmit='updateInvoice'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-select-field
          label='Payment Method'
          v-model='payment_method'
          name='payment_method'
          :options="options"
          validationRules='required'
        />

        <b-form-group label="Send Receipt">
          <b-form-checkbox
            id="send-receipt"
            v-model="sendReceipt"
            name="send-receipt"
            :value='true'
            :unchecked-value='false'
          />

          <app-email-form
            v-if='sendReceipt'
            :value='emailDefinition'
            @changed='payload => updateEmailContent(payload)'
          ></app-email-form>
        </b-form-group>
      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import InvoiceForm from '../forms/full';
import EmailForm from '../../common/forms/email';
import EventBus from '@/store/eventBus'
import { receiptContent } from '../../../content/emailContent';
import { paymentReceived } from '@/components/estimate/utils/stateTransitions.js';
import { PAYMENT_METHODS } from '@/constants';
import { EmailDefinition } from '@/models';

export default {
  components: {
    'app-invoice-form': InvoiceForm,
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
      payment_method: null,
      sendReceipt: true,
      options: PAYMENT_METHODS,
      emailDefinition: null
    }
  },
  methods: {
    updateInvoice() {
      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }
        var params = {
          invoice: { payment_method: this.payment_method },
          send_receipt: this.sendReceipt,
          email: this.emailDefinition
        }

        paymentReceived(this.estimate, params).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('ESTIMATE_UPDATED', response.data);
        })
      })
    },
    updateEmailContent(new_email) {
      this.emailDefinition = { ...new_email }
    },
  },
  watch: {
    estimate: {
      immediate: true,
      handler() {
        this.payment_method = this.estimate.invoice.payment_method;

        this.emailDefinition = new EmailDefinition(
          this.estimate.customer_detail.email,
          'Big Tree Services Receipt',
          receiptContent
        )
      }
    }
  }
}
</script>

<style scoped>

</style>
