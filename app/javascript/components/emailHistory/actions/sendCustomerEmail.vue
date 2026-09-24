<template>
  <app-right-sidebar :id='id' title='Send Customer Email' submitText='Send' :onSubmit='send'>
    <template v-slot:content>
      <app-select-field
        label='Email Template'
        v-model='selectedTemplateKey'
        name='emailTemplate'
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
import { EMAIL_CATEGORIES, categoryFor, categoryAvailable, formatTemplateKey } from '@/content/emailCategories';

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
      templates: [],
      selectedTemplateKey: null,
      includeQuote: false
    }
  },
  computed: {
    // One optgroup per workflow step, so a resend is picked by the step it belongs to. Steps the
    // estimate has not reached yet are left out, as are steps with no templates written for them.
    templateOptions() {
      const groups = EMAIL_CATEGORIES
        .filter(category => categoryAvailable(category.key, this.estimate.status))
        .map(category => ({
          label: category.label,
          options: this.templates
            .filter(template => template.category === category.key)
            .map(template => ({ value: template.key, text: formatTemplateKey(template.key) }))
        }))
        .filter(group => group.options.length > 0);

      return [{ value: null, text: '— Select a template —' }].concat(groups);
    },
    selectedTemplate() {
      return this.templates.find(template => template.key === this.selectedTemplateKey);
    }
  },
  methods: {
    handleChange(payload) {
      this.emailDefinition = { ...payload }
    },
    async send() {
      if (!this.emailDefinition || !this.selectedTemplate) { return; }

      const endpoint = categoryFor(this.selectedTemplate.category).endpoint;
      const response = await this.axiosPost(`/estimates/${this.estimate.id}/${endpoint}`, {
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
      this.templates = response.data.email_templates;
    })
  }
}
</script>

<style scoped>
  .attach-quote-row {
    margin-bottom: 16px;
  }
</style>
