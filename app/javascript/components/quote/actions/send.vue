<template>
  <app-right-sidebar :id='id' title='Send Quote' submitText='Send' :onSubmit='sendQuote'>
    <template v-slot:content>
      <app-email-form :value='emailDefinition' @changed='payload => handleChange(payload)'>
      </app-email-form>
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/email';
import OrganizationEstimateMailer from '../../../content/organizationEstimateMailer'
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
      estimateMailer: new OrganizationEstimateMailer(this.$store.state.organization, this.estimate)
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
      this.axiosPost(`/estimates/${this.estimate.id}/quote_mailouts`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
      })
    }
  },
  computed: {
    subject() {
      return `Your Quote from ${this.$store.state.organization.name}`
    }
  },
  mounted(){
    console.log(this.$store.state.organization)
  },
  watch: {
    estimate: {
      immediate: true,
      handler() {
        this.emailDefinition = new EmailDefinition(
          this.estimate.customer_detail.email,
          this.subject,
          this.estimateMailer.quoteContent()
        )
      }
    }
  }
}
</script>

<style scoped>

</style>
