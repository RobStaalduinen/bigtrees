<template>
  <app-right-sidebar :id='id' title='Send Followup' submitText='Send' :onSubmit='sendFollowup'>
    <template v-slot:content>
      <app-select-field
        v-if='templateOptions.length > 0'
        label='Followup Template'
        v-model='selectedTemplateKey'
        name='followupTemplate'
        :options='templateOptions'
        validationRules='required'
      />

      <app-email-form
        v-if='selectedTemplateKey'
        :value='emailDefinition'
        @changed='payload => handleChange(payload)'
        :template='selectedTemplateKey'
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
import EmailForm from '../../common/forms/templatedEmail';
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
      followupTemplates: [],
      selectedTemplateKey: null,
      includeQuote: false
    }
  },
  computed: {
    templateOptions() {
      return this.followupTemplates.map(t => ({
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
  },
  mounted() {
    this.axiosGet('/email_templates').then(response => {
      this.followupTemplates = response.data.email_templates.filter(t => t.category === 'followup');
      if (this.followupTemplates.length > 0) {
        this.selectedTemplateKey = this.followupTemplates[0].key;
      }
    })
  }
}
</script>

<style scoped>
  .attach-quote-row {
    margin-bottom: 16px;
  }
</style>
