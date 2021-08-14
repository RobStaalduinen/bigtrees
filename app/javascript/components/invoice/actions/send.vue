<template>
  <app-right-sidebar :id='id' title='Send Invoice' submitText='Send' :onSubmit='sendInvoice' :alternateAction='skipSend'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-datepicker
          v-model='workCompletionDate'
          locale='en-CA'
          id='work-date'
          name='work-date'
          label='Work Completed Date'
          validationRules='required'
        >
        </app-datepicker>

        <app-email-form :value='emailDefinition' @changed='payload => handleChange(payload)'></app-email-form>
      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/email';
import { invoiceContent } from '../../../content/emailContent';
import { invoiceSent } from '@/components/estimate/utils/stateTransitions';
import EventBus from '@/store/eventBus'
import { EmailDefinition } from '@/models';

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
      emailDefinition: null,
      workCompletionDate: null
    }
  },
  methods: {
    handleChange(new_email) {
      this.emailDefinition = { ...new_email }
    },
    sendInvoice() {
      var params = {
        estimate: { work_completion_date: this.workCompletionDate },
        dest_email: this.emailDefinition.email,
        content: this.emailDefinition.content,
        subject: this.emailDefinition.subject
      }

      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }

        invoiceSent(this.estimate, params).then(response => {
          EventBus.$emit('ESTIMATE_UPDATED', response.data);
          this.$root.$emit('bv::toggle::collapse', this.id);
        })
      })
    },
    skipSend() {
      var params = {
        estimate: { work_completion_date: this.workCompletionDate },
        skip_mail: true
      }


      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }

        invoiceSent(this.estimate, params).then(response => {
          EventBus.$emit('ESTIMATE_UPDATED', response.data);
          this.$root.$emit('bv::toggle::collapse', this.id);
        })
      })

    }
  },
  watch: {
    estimate: {
      immediate: true,
      handler() {
        this.emailDefinition = new EmailDefinition(
          this.estimate.customer.email,
          'Big Tree Services Final Invoice',
          invoiceContent
        )
      }
    }
  }

}
</script>

<style scoped>

</style>
