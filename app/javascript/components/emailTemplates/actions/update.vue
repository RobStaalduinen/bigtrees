<template>
  <app-right-sidebar :id='id' title='Update Template' submitText='Submit' :onSubmit='updateTemplate' @cancelled="reset">
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-input-field
          v-model='subject'
          name='subject'
          label='Subject'
          validationRules='required'
        />

        <app-text-area
          v-model="content"
          name="template-content"
          label='Content'
          validationRules='required'
          :noResize='true'
          :rows=20
        />

      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>

import EventBus from '@/store/eventBus';

export default {
  props: {
    id: {
      required: true
    },
    emailTemplate: {
      required: true
    }
  },
  data() {
    return {
      subject: null,
      content: null
    }
  },
  methods: {
    updateTemplate() {
      this.$refs.observer.validate().then(success => {
        if(!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
        }

        if(success) {
          this.axiosPut(`/email_templates/${this.emailTemplate.key}`, {
            email_template: {
              subject: this.subject,
              content: this.content,
            }
          }).then(response => {
            this.$root.$emit('bv::toggle::collapse', this.id);
            this.reset();
            this.$emit('changed', response.data.email_template);
          })
        }
      })
    },
    reset() {
      this.subject = this.emailTemplate.subject;
      this.content = this.emailTemplate.content;
    }
  },
  watch: {
    emailTemplate() {
      if(this.emailTemplate) {
        this.subject = this.emailTemplate.subject;
        this.content = this.emailTemplate.content;
      }
    }
  }
}

</script>
