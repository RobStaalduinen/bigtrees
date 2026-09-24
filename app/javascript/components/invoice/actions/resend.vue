<template>
  <app-right-sidebar :id='id' title='Resend Invoice' submitText='Send' :onSubmit='sendInvoice'>
    <template v-slot:content>
      <app-email-form
        :value='emailDefinition'
        @changed='payload => handleChange(payload)'
        @template-changed='key => templateKey = key'
        category='invoice'
        defaultTemplateKey='invoice_mailout'
        :estimate='estimate'
      ></app-email-form>
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/categorisedEmail';

export default {
  components: {
    'app-email-form': EmailForm
  },
  props: {
    id: {
      required: true
    },
    estimate: {
      required: true
    }
  },
  data() {
    return {
      emailDefinition: null,
      templateKey: 'invoice_mailout'
    }
  },
  methods: {
    handleChange(new_email) {
      this.emailDefinition = { ...new_email }
    },
    sendInvoice() {
      var params = {
        dest_email: this.emailDefinition.email,
        content: this.emailDefinition.content,
        subject: this.emailDefinition.subject,
        template_key: this.templateKey
      }
      this.axiosPost(`/estimates/${this.estimate.id}/quote_mailouts`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
      })
    }
  }
}
</script>

<style scoped>

</style>
