<template>
    <div class="email-templates">
      <div class="email-template-section-header">
        <div class="email-template-section-title">Email Templates</div>
        <router-link class="email-template-new" to="/admin/email_templates/new">New</router-link>
      </div>

      <p class="email-template-description">
        Every template belongs to a step of the workflow, and the send form at that step offers
        each template filed under it.
      </p>

      <div v-if="sortedTemplates.length === 0" class="email-template-empty">
        No templates.
      </div>

      <app-collapsable
        v-for="emailTemplate in sortedTemplates"
        :key="emailTemplate.id"
        :id="`email-template-${emailTemplate.id}`"
        class="email-template"
      >
        <template v-slot:title>
          <div class="email-template-title">
            <span>{{ formatTitle(emailTemplate.key) }}</span>
            <app-pill :text="categoryLabel(emailTemplate)" tone="neutral" filled />
          </div>
        </template>

        <template v-slot:content>
          <div class='email-template-header'><b>Subject</b></div>

          {{ emailTemplate.subject }}
          <div class="email-template-header"><b>Body</b></div>
          <div class="email-body">
            {{ emailTemplate.content }}
          </div>

          <div class='single-estimate-link-row'>
            <div class='single-estimate-link template-actions'>
              <b-icon icon='pencil-square' class='app-icon template-action-icon' @click="editTemplate(emailTemplate)"></b-icon>
              <template v-if="emailTemplate.deletable">
                <div class='template-action-divider'></div>
                <b-icon
                  icon='trash'
                  class='app-icon template-action-icon'
                  @click="deleteTemplate(emailTemplate)"
                ></b-icon>
              </template>
            </div>
          </div>
        </template>
      </app-collapsable>

      <app-email-insertables />
    </div>
</template>

<script>

import EmailInsertables from '@/components/emailInsertables/views/list';
import { categoryLabelFor, categoryOrder, formatTemplateKey } from '@/content/emailCategories';

export default {
  components: {
    'app-email-insertables': EmailInsertables
  },
  data() {
    return {
      emailTemplates: []
    }
  },
  computed: {
    // One list in workflow order, so templates for the same step still sit together.
    sortedTemplates() {
      return [...this.emailTemplates].sort((a, b) =>
        categoryOrder(a.category) - categoryOrder(b.category) || a.key.localeCompare(b.key)
      );
    }
  },
  methods: {
    retrieveEmailTemplates() {
      this.axiosGet(`/email_templates`).then(response => {
        this.emailTemplates = response.data.email_templates;
      })
    },
    categoryLabel(template) {
      return categoryLabelFor(template.category);
    },
    editTemplate(template) {
      this.$router.push(`/admin/email_templates/${template.key}`);
    },
    deleteTemplate(template) {
      if (confirm(`Delete the "${this.formatTitle(template.key)}" template?`)) {
        this.axiosDelete(`/email_templates/${template.key}`).then(() => {
          this.emailTemplates = this.emailTemplates.filter(t => t.id !== template.id);
        });
      }
    },
    formatTitle(key) {
      return formatTemplateKey(key);
    }
  },
  mounted() {
    this.retrieveEmailTemplates();
  }

}
</script>

<style scoped>
.email-templates {
  margin-top: 8px;
}

.email-template-section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--space-2);
  padding-bottom: var(--space-1);
  border-bottom: 1px solid var(--border-strong);
}

.email-template-section-title {
  font-size: 1.1rem;
  font-weight: 600;
}

.email-template-new {
  white-space: nowrap;
  cursor: pointer;
}

.email-template-description {
  font-size: var(--text-sm);
  color: var(--text-muted);
  margin-bottom: var(--space-3);
}

.email-template-empty {
  font-size: 0.85rem;
  color: #888;
  margin-bottom: 8px;
}

.email-template {
  margin-bottom: 8px;
}

/* Fills the collapsable header so the category pill sits against its right edge. */
.email-template-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--space-2);
  flex: 1;
}

.email-template-header {
  margin-top: 8px;
  margin-bottom: 8px;
  padding-bottom: 4px;

  border-bottom: 1px solid #ccc;
}

.email-body {
  white-space: pre-line;
}

.template-actions {
  display: flex;
  align-items: center;
}

.template-action-icon {
  margin: 0 12px;
}

.template-action-divider {
  width: 1px;
  height: 18px;
  background-color: #ccc;
}
</style>
