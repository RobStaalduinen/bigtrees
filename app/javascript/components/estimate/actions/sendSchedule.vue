<template>
  <app-right-sidebar :id='id' title='Send Schedule Email' submitText='Send' :onSubmit='sendScheduleEmail'>
    <template v-slot:content>
      <app-email-form
        :value='emailDefinition'
        @changed='payload => handleChange(payload)'
        @template-changed='key => selectedTemplateKey = key'
        category='scheduling'
        pickerLabel='Schedule Template'
        :estimate='estimate'
      />
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/categorisedEmail'
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
      selectedTemplateKey: null
    }
  },
  methods: {
    handleChange(payload) {
      this.emailDefinition = { ...payload }
    },
    async sendScheduleEmail() {
      if (!this.emailDefinition || !this.selectedTemplateKey) { return; }

      const response = await this.axiosPost(`/estimates/${this.estimate.id}/scheduling_mailouts`, {
        dest_email: this.emailDefinition.email,
        subject: this.emailDefinition.subject,
        content: this.emailDefinition.content,
        template_key: this.selectedTemplateKey
      })

      this.$root.$emit('bv::toggle::collapse', this.id)
      EventBus.$emit('ESTIMATE_UPDATED', response.data)
    }
  }
}
</script>
