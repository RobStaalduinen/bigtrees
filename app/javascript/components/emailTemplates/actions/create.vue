<template>
  <app-right-sidebar :id='id' title='New Scheduling Template' submitText='Create' :onSubmit='createTemplate' @cancelled="reset">
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-input-field
          v-model='title'
          name='title'
          label='Title'
          validationRules='required'
        />

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
    }
  },
  data() {
    return {
      title: null,
      subject: null,
      content: null
    }
  },
  methods: {
    createTemplate() {
      this.$refs.observer.validate().then(success => {
        if(!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }

        this.axiosPost(`/email_templates`, {
          email_template: {
            title: this.title,
            subject: this.subject,
            content: this.content,
          }
        }).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          this.reset();
          this.$emit('changed', response.data.email_template);
        })
      })
    },
    reset() {
      this.title = null;
      this.subject = null;
      this.content = null;
    }
  }
}

</script>
