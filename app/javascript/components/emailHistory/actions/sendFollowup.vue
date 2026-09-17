<template>
  <app-right-sidebar :id='id' title='Send Followup' submitText='Send' :onSubmit='sendFollowup'>
    <template v-slot:content>
      <app-email-form
        :value='emailDefinition'
        @changed='payload => handleChange(payload)'
        @template-changed='key => selectedTemplateKey = key'
        category='followup'
        pickerLabel='Followup Template'
        :estimate='estimate'
      >
        <template v-slot:pre-body>
          <div class='attach-quote-row'>
            <app-checkbox-right-label
              id='attach-quote-pdf'
              label='Attach Quote PDF'
              v-model='includeQuote'
            />
          </div>
        </template>
      </app-email-form>
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/categorisedEmail';
import EventBus from '@/store/eventBus';

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
      selectedTemplateKey: null,
      includeQuote: false
    }
  },
  methods: {
    handleChange(payload) {
      this.emailDefinition = { ...payload }
    },
    async sendFollowup() {
      if (!this.emailDefinition || !this.selectedTemplateKey) { return; }

      const response = await this.axiosPost(`/estimates/${this.estimate.id}/followups`, {
        dest_email: this.emailDefinition.email,
        subject: this.emailDefinition.subject,
        content: this.emailDefinition.content,
        template_key: this.selectedTemplateKey,
        include_quote: this.includeQuote
      })

      this.$root.$emit('bv::toggle::collapse', this.id)
      EventBus.$emit('ESTIMATE_UPDATED', response.data)
    }
  }
}
</script>

<style scoped>
  .attach-quote-row {
    margin-bottom: 16px;
  }
</style>
