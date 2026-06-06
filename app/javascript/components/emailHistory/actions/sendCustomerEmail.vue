<template>
  <app-right-sidebar :id='id' title='Send Customer Email' submitText='Send' :onSubmit='send'>
    <template v-slot:content>
      <div class='email-type-toggle'>
        <app-segmented-control v-model='emailType' :options='typeOptions' />
      </div>

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

// The three customer-facing email types, each backed by a template category
// and a dedicated send endpoint.
const EMAIL_TYPES = {
  followup:   { label: 'Followup', category: 'followup',   endpoint: 'followups' },
  scheduling: { label: 'Schedule', category: 'scheduling', endpoint: 'scheduling_mailouts' },
  default:    { label: 'Workflow', category: 'default',    endpoint: 'quote_mailouts' }
};

// Estimate statuses in pipeline order (mirrors the Estimate#status enum).
const STATUS_ORDER = [
  'needs_costs', 'needs_arborist', 'pending_quote', 'quote_sent',
  'approved', 'work_scheduled', 'work_started', 'work_paused',
  'work_completed', 'final_invoice_sent', 'completed'
];

const atLeast = (status, threshold) =>
  STATUS_ORDER.indexOf(status) >= STATUS_ORDER.indexOf(threshold);

// Workflow (default-category) emails are only for resending steps already
// reached in the normal flow, so each is gated by the estimate's status.
// Templates without a rule here are always available.
const WORKFLOW_TEMPLATE_RULES = {
  quote_mailout:    status => atLeast(status, 'quote_sent'),
  approval_mailout: status => atLeast(status, 'approved'),
  invoice_mailout:  status => atLeast(status, 'final_invoice_sent'),
  receipt_mailout:  status => status === 'completed',
  job_progress:     status => ['work_paused', 'work_completed'].includes(status)
};

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
      emailType: 'followup',
      selectedTemplateKey: null,
      includeQuote: false
    }
  },
  computed: {
    typeOptions() {
      return Object.keys(EMAIL_TYPES).map(value => ({ value, text: EMAIL_TYPES[value].label }));
    },
    templateOptions() {
      const options = this.templates
        .filter(t => t.category === EMAIL_TYPES[this.emailType].category)
        .filter(t => this.templateAvailable(t))
        .map(t => ({ value: t.key, text: this.formatLabel(t.key) }));

      return [{ value: null, text: '— Select a template —' }].concat(options);
    }
  },
  methods: {
    formatLabel(key) {
      return key.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase());
    },
    // Followup/scheduling templates are always available; workflow templates
    // are gated by the estimate's current pipeline status.
    templateAvailable(template) {
      const rule = WORKFLOW_TEMPLATE_RULES[template.key];
      return rule ? rule(this.estimate.status) : true;
    },
    handleChange(payload) {
      this.emailDefinition = { ...payload }
    },
    async send() {
      if (!this.emailDefinition || !this.selectedTemplateKey) { return; }

      const endpoint = EMAIL_TYPES[this.emailType].endpoint;
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
  },
  watch: {
    // Switching email type swaps the available templates; clear the selection
    // so the dropdown returns to its empty state.
    emailType() {
      this.selectedTemplateKey = null;
    }
  }
}
</script>

<style scoped>
  .email-type-toggle {
    margin-bottom: 16px;
  }

  .attach-quote-row {
    margin-bottom: 16px;
  }
</style>
