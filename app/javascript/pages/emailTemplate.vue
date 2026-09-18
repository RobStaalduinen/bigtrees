<template>
  <page-template>
    <app-header :title='pageTitle' :backLink='listLink' />

    <div id='email-template-page' v-if='loaded'>
      <validation-observer ref='observer'>
        <app-input-field
          v-if='isNew'
          v-model='title'
          name='title'
          label='Title'
          validationRules='required'
        />

        <app-select-field
          v-if='isNew'
          v-model='category'
          name='category'
          label='Workflow Step'
          :options='categoryOptions'
          validationRules='required'
        />

        <div v-else class='template-readonly-field'>
          <div class='template-readonly-label'>Workflow Step</div>
          <div>{{ categoryLabel }}</div>
        </div>

        <p class='template-step-hint'>{{ categoryDescription }}</p>

        <app-input-field
          v-model='subject'
          name='subject'
          label='Subject'
          validationRules='required'
        />

        <app-text-area
          v-model='content'
          name='content'
          label='Content'
          :noResize='true'
          :rows=20
        />
      </validation-observer>

      <div v-if='formError' class='template-form-error'>{{ formError }}</div>

      <div id='email-template-actions'>
        <app-button text='Cancel' variant='outline' :click='cancel' />
        <div id='email-template-submit'>
          <app-submit-button :label='submitLabel' :onSubmit='submit' />
        </div>
      </div>
    </div>
  </page-template>
</template>

<script>

import EventBus from '@/store/eventBus';
import { EMAIL_CATEGORIES, categoryFor } from '@/content/emailCategories';

const LIST_LINK = '/admin/company?section=email_templates';

export default {
  data() {
    return {
      templateKey: this.$route.params.key || null,
      loaded: false,
      title: null,
      category: null,
      subject: null,
      content: null,
      formError: null
    }
  },
  computed: {
    isNew() {
      return this.templateKey == null;
    },
    listLink() {
      return LIST_LINK;
    },
    pageTitle() {
      return this.isNew ? 'New Email Template' : 'Edit Email Template';
    },
    submitLabel() {
      return this.isNew ? 'Create' : 'Save';
    },
    categoryOptions() {
      return EMAIL_CATEGORIES.map(category => ({ value: category.key, text: category.label }));
    },
    selectedCategory() {
      return categoryFor(this.category);
    },
    categoryLabel() {
      return this.selectedCategory ? this.selectedCategory.label : '';
    },
    categoryDescription() {
      return this.selectedCategory ? this.selectedCategory.description : '';
    }
  },
  methods: {
    cancel() {
      this.$router.push(LIST_LINK);
    },
    validate() {
      this.formError = null;

      if (!this.content || !this.content.trim()) {
        this.formError = 'The template needs some content.';
      }

      return this.formError == null;
    },
    submit() {
      this.$refs.observer.validate().then(success => {
        if (!success || !this.validate()) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }

        const request = this.isNew
          ? this.axiosPost('/email_templates', {
              email_template: {
                title: this.title,
                category: this.category,
                subject: this.subject,
                content: this.content
              }
            })
          : this.axiosPut(`/email_templates/${this.templateKey}`, {
              email_template: { subject: this.subject, content: this.content }
            });

        request.then(() => {
          this.$router.push(LIST_LINK);
        }).catch(error => {
          this.formError = this.serverError(error);
          EventBus.$emit('FORM_VALIDATION_FAILED');
        })
      })
    },
    // The controller renders the offending fields, i.e. { title: ["can't be blank"] }.
    serverError(error) {
      const errors = error.response && error.response.data;

      if (!errors || typeof errors !== 'object') {
        return 'The template could not be saved.';
      }

      return Object.keys(errors)
        .map(field => `${field.replace(/_/g, ' ')} ${[].concat(errors[field]).join(', ')}`)
        .join('. ');
    },
    loadTemplate() {
      if (this.isNew) {
        this.category = EMAIL_CATEGORIES[0].key;
        this.loaded = true;
        return;
      }

      this.axiosGet(`/email_templates/${this.templateKey}`).then(response => {
        const template = response.data.email_template;

        this.category = template.category;
        this.subject = template.subject;
        this.content = template.content;
        this.loaded = true;
      }).catch(() => {
        this.$router.push(LIST_LINK);
      })
    }
  },
  mounted() {
    this.loadTemplate();
  }
}

</script>

<style scoped>
  #email-template-page {
    max-width: 720px;
  }

  .template-readonly-field {
    margin-bottom: 1rem;
  }

  .template-readonly-label {
    font-size: var(--text-sm);
    margin-bottom: var(--space-1);
  }

  .template-step-hint {
    font-size: var(--text-xs);
    color: var(--text-muted);
    margin-top: calc(-1 * var(--space-2));
    margin-bottom: var(--space-4);
  }

  .template-form-error {
    font-size: var(--text-xs);
    font-style: italic;
    color: var(--danger);
    margin-bottom: var(--space-2);
  }

  #email-template-actions {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: var(--space-2);

    padding-top: var(--space-3);
    border-top: 1px solid var(--border);
  }

  /* .submit-button is width:100%, so it needs a bounded holder inside the action row. */
  #email-template-submit {
    width: 160px;
  }
</style>
