<template>
  <app-right-sidebar :id='id' title='Send Quote' submitText='Send' :onSubmit='sendQuote' :alternateAction='skipSend'>
    <template v-slot:content>
      <app-email-form :value='emailDefinition' @changed='payload => handleChange(payload)'></app-email-form>
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/email';
import { quoteContent } from '../../../content/emailContent';
import moment from 'moment';
import EventBus from '@/store/eventBus'

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
        content: quoteContent,
        subject: 'Quote from Big Tree'
      }
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
        subject: this.emailDefinition.subject,
        quote_sent_date: moment().format('YYYY-MM-DD')
      }
      this.axiosPost(`/estimates/${this.estimate.id}/quote_mailouts`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
      })
    },
    skipSend() {
      var params = {
        estimate: { quote_sent_date: moment().format('YYYY-MM-DD') }
      }

      this.axiosPut(`/estimates/${this.estimate.id}`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
      })
    }
  },
  watch: {
    estimate() {
      this.emailDefinition.email = this.estimate.customer.email;
    }
  }
}
</script>

<style scoped>

</style>
