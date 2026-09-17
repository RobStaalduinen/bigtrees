<template>
  <div>
    <app-select-field
      v-if='templateOptions.length > 1'
      :label='pickerLabel'
      :value='selectedKey'
      @input='selectTemplate'
      :name='`${category}_template`'
      :options='templateOptions'
      validationRules='required'
    />

    <app-email-form
      v-if='selectedKey'
      :value='value'
      @changed='payload => $emit("changed", payload)'
      :template='selectedKey'
      :estimate='estimate'
    >
      <template v-slot:pre-body>
        <slot name='pre-body'></slot>
      </template>
    </app-email-form>
  </div>
</template>

<script>

import EmailForm from '@/components/common/forms/templatedEmail';
import { formatTemplateKey } from '@/content/emailCategories';

// Wraps the templated email form with a picker over every template an organization has written
// for one workflow step. The picker stays hidden while a category holds a single template, so a
// step only grows a dropdown once there is a genuine choice to make.
export default {
  components: {
    'app-email-form': EmailForm
  },
  props: {
    category: {
      required: true,
      type: String
    },
    // The seeded template for this step — selected first whenever it is still present.
    defaultTemplateKey: {
      required: false,
      type: String,
      default: null
    },
    estimate: {
      required: true
    },
    value: {
      required: false,
      default: null
    },
    pickerLabel: {
      required: false,
      type: String,
      default: 'Email Template'
    }
  },
  data() {
    return {
      templates: [],
      selectedKey: null
    }
  },
  computed: {
    templateOptions() {
      return this.templates.map(template => ({
        value: template.key,
        text: formatTemplateKey(template.key)
      }))
    }
  },
  methods: {
    selectTemplate(key) {
      this.selectedKey = key;
      this.$emit('template-changed', key);
    },
    loadTemplates() {
      return this.axiosGet('/email_templates').then(response => {
        const templates = response.data.email_templates.filter(t => t.category === this.category);

        // The seeded template leads the list; anything the organization added follows.
        this.templates = templates.sort((a, b) => {
          if (a.key === this.defaultTemplateKey) { return -1; }
          if (b.key === this.defaultTemplateKey) { return 1; }
          return 0;
        });

        if (this.templates.length > 0) {
          this.selectTemplate(this.templates[0].key);
        }
      })
    }
  },
  mounted() {
    this.loadTemplates();
  }
}

</script>
