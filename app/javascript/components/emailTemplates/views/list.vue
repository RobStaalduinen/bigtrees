<template>
    <div class="email-templates">
      <app-collapsable v-for="emailTemplate in emailTemplates" :id='emailTemplate.id' class="email-template">
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
            </div>
          </div>
        </template>
      </app-collapsable>

      <app-template-update id='template-update' :emailTemplate='templateToEdit' @changed='retrieveEmailTemplates' />

    </div>
</template>

<script>

import TemplateUpdate from '@/components/emailTemplates/actions/update';

export default { 
  components: {
    'app-template-update': TemplateUpdate
  },
  data() {
    return {
      emailTemplates: [],
      templateToEdit: null
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