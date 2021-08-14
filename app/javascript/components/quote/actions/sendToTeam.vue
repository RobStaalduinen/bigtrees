<template>
  <app-right-sidebar :id='id' title='Send Quote' submitText='Send' :onSubmit='sendQuote'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-email-form :value='emailDefinition' @changed='payload => handleChange(payload)'></app-email-form>
      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/emailArboristSelect';
import { quoteContent } from '../../../content/emailContent';
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
      emailDefinition: null
    }
  },
  methods: {
    handleChange(new_email) {
      this.emailDefinition = { ...new_email }
    },
    sendQuote() {
      var params = {
        dest_email: this.emailDefinition.email,
        content: this.emailDefinition.content,
        subject: this.emailDefinition.subject
      }
      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return
        }
        else {
          this.axiosPost(`/estimates/${this.estimate.id}/quote_mailouts`, params).then(response => {
            this.$root.$emit('bv::toggle::collapse', this.id);
          })
        }
      })
    },
    subject() {
      var address = null;
      var customer = null

      if(this.estimate.site && this.estimate.site.address) {
        address = this.estimate.site.address.full_address
      }

      if(this.estimate.customer) {
        customer = this.estimate.customer.name;
      }

      return `Quote - ${customer} - ${address}`
    }
  },
  watch: {
    estimate: {
      immediate: true,
      handler() {
        this.emailDefinition = new EmailDefinition(
          null,
          this.subject(),
          'Take a look at this quote'
        )
      }
    }
  }
}
</script>
