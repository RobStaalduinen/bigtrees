<template>
    <div class="email-templates">
      <div v-for="group in groups" :key="group.category" class="email-template-group">
        <div class="email-template-group-header">
          <div class="email-template-group-title">{{ group.label }}</div>
          <a
            v-if="group.userManaged"
            class="email-template-new"
            @click="openCreate(group.category)"
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
              <div class='single-estimate-link template-actions'>
                <b-icon icon='pencil-square' class='app-icon template-action-icon' @click="editTemplate(emailTemplate)"></b-icon>
                <template v-if="userManagedCategories.includes(emailTemplate.category)">
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
      </div>

      <app-template-update id='template-update' :emailTemplate='templateToEdit' @changed='retrieveEmailTemplates' />
      <app-template-create
        id='template-create-followup'
        category='followup'
        @changed='retrieveEmailTemplates'
      />
      <app-template-create
        id='template-create-scheduling'
        category='scheduling'
        @changed='retrieveEmailTemplates'
      />

    </div>
</template>

<script>

import TemplateUpdate from '@/components/emailTemplates/actions/update';
import TemplateCreate from '@/components/emailTemplates/actions/create';

const GROUP_DEFINITIONS = [
  { category: 'default', label: 'System', userManaged: false },
  { category: 'followup', label: 'Followup', userManaged: true },
  { category: 'scheduling', label: 'Scheduling', userManaged: true }
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
    },
    userManagedCategories() {
      return GROUP_DEFINITIONS.filter(g => g.userManaged).map(g => g.category);
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
    openCreate(category) {
      this.$root.$emit('bv::toggle::collapse', `template-create-${category}`);
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
