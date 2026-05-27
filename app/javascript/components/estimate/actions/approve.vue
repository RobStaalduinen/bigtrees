<template>
  <app-right-sidebar :id='id' title='Approve' submitText='Approve' :onSubmit='approveEstimate'>
    <template v-slot:content>
      <div class='approve-label'>Customer has approved work?</div>
      <b-form-checkbox v-model='sendEmail' class='send-email-toggle'>
        Send approval email
      </b-form-checkbox>
      <app-email-form
        v-if='sendEmail'
        :value='emailDefinition'
        @changed='payload => handleChange(payload)'
        template='approval_mailout'
        :estimate='estimate'
      />
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/templatedEmail'
import EventBus from '@/store/eventBus'

export default {
  components: {
    'app-email-form': EmailForm
  },
  props: {
    id: { required: true },
    estimate: { required: true }
  },
  data() {
    return {
      emailDefinition: null,
      sendEmail: true
    }
  },
  methods: {
    handleChange(payload) {
      this.emailDefinition = { ...payload }
    },
    async approveEstimate() {
      const approveResp = await this.axiosPut(`/estimates/${this.estimate.id}`, {
        estimate: { approved: true }
      })

      if (this.sendEmail && this.emailDefinition) {
        await this.axiosPost(`/estimates/${this.estimate.id}/approval_mailouts`, {
          dest_email: this.emailDefinition.email,
          subject: this.emailDefinition.subject,
          content: this.emailDefinition.content
        })
      }

      this.$root.$emit('bv::toggle::collapse', this.id)
      EventBus.$emit('ESTIMATE_UPDATED', approveResp.data)
    }
  }
}
</script>

<style scoped>
  .approve-label {
    margin-bottom: 8px;
  }

  .send-email-toggle {
    margin-bottom: 16px;
  }
</style>
