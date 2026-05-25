<template>
    <div class="email-templates">
      <div v-for="group in groups" :key="group.category" class="email-template-group">
        <div class="email-template-group-header">
          <div class="email-template-group-title">{{ group.label }}</div>
          <a
            v-if="group.category === 'scheduling'"
            class="email-template-new"
            @click="openCreate"
          >
            New
          </a>
        </div>

        <div v-if="group.templates.length === 0" class="email-template-empty">
          No templates.
        </div>

        <app-collapsable
          v-for="emailTemplate in group.templates"
          :key="emailTemplate.id"
          :id="`email-template-${emailTemplate.id}`"
          class="email-template"
        >
          <template v-slot:title>
            {{ formatTitle(emailTemplate.key) }}
          </template>

          <template v-slot:content>
            <div class='email-template-header'><b>Subject</b></div>

            {{ emailTemplate.subject }}
            <div class="email-template-header"><b>Body</b></div>
            <div class="email-body">
              {{ emailTemplate.content }}
            </div>

            <div class='single-estimate-link-row'>
              <div class='single-estimate-link'>
                <b-icon icon='pencil-square' class='app-icon' @click="editTemplate(emailTemplate)"></b-icon>
                <b-icon
                  v-if="emailTemplate.category === 'scheduling'"
                  icon='trash'
                  class='app-icon'
                  @click="deleteTemplate(emailTemplate)"
                ></b-icon>
              </div>
            </div>
          </template>
        </app-collapsable>
      </div>

      <app-template-update id='template-update' :emailTemplate='templateToEdit' @changed='retrieveEmailTemplates' />
      <app-template-create id='template-create' @changed='retrieveEmailTemplates' />

    </div>
</template>

<script>

import TemplateUpdate from '@/components/emailTemplates/actions/update';
import TemplateCreate from '@/components/emailTemplates/actions/create';

const GROUP_DEFINITIONS = [
  { category: 'default', label: 'System' },
  { category: 'followup', label: 'Followup' },
  { category: 'scheduling', label: 'Scheduling' }
];

export default {
  components: {
    'app-template-update': TemplateUpdate,
    'app-template-create': TemplateCreate
  },
  data() {
    return {
      emailTemplates: [],
      templateToEdit: null
    }
  },
  computed: {
    groups() {
      return GROUP_DEFINITIONS.map(group => ({
        ...group,
        templates: this.emailTemplates.filter(t => t.category === group.category)
      }));
    }
  },
  methods: {
    retrieveEmailTemplates() {
      this.axiosGet(`/email_templates`).then(response => {
        this.emailTemplates = response.data.email_templates;
      })
    },
    editTemplate(template) {
      this.templateToEdit = template;
      this.$root.$emit('bv::toggle::collapse', 'template-update');
    },
    openCreate() {
      this.$root.$emit('bv::toggle::collapse', 'template-create');
    },
    deleteTemplate(template) {
      if (confirm(`Delete the "${this.formatTitle(template.key)}" template?`)) {
        this.axiosDelete(`/email_templates/${template.key}`).then(() => {
          this.emailTemplates = this.emailTemplates.filter(t => t.id !== template.id);
        });
      }
    },
    formatTitle(title) {
      return title.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase());
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

.email-template-group {
  margin-bottom: 24px;
}

.email-template-group-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
  padding-bottom: 4px;
  border-bottom: 1px solid #ccc;
}

.email-template-group-title {
  font-size: 1.1rem;
  font-weight: 600;
}

.email-template-new {
  cursor: pointer;
}

.email-template-empty {
  font-size: 0.85rem;
  color: #888;
  margin-bottom: 8px;
}

.email-template {
  margin-bottom: 8px;
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
</style>
