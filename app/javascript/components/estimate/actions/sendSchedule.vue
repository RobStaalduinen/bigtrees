<template>
  <app-right-sidebar :id='id' title='Send Schedule Email' submitText='Send' :onSubmit='sendScheduleEmail'>
    <template v-slot:content>
      <app-select-field
        v-if='templateOptions.length > 0'
        label='Schedule Template'
        v-model='selectedTemplateKey'
        name='scheduleTemplate'
        :options='templateOptions'
        validationRules='required'
      />
      <app-email-form
        v-if='selectedTemplateKey'
        :value='emailDefinition'
        @changed='payload => handleChange(payload)'
        :template='selectedTemplateKey'
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
      schedulingTemplates: [],
      selectedTemplateKey: null
    }
  },
  computed: {
    templateOptions() {
      return this.schedulingTemplates.map(t => ({
        value: t.key,
        text: this.formatLabel(t.key)
      }))
    }
  },
  methods: {
    formatLabel(key) {
      return key.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase());
    },
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
  },
  mounted() {
    this.axiosGet('/email_templates').then(response => {
      this.schedulingTemplates = response.data.email_templates.filter(t => t.category === 'scheduling');
      if (this.schedulingTemplates.length > 0) {
        this.selectedTemplateKey = this.schedulingTemplates[0].key;
      }
    })
  }
}
</script>
