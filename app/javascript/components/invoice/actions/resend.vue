<template>
  <app-right-sidebar :id='id' title='Resend Invoice' submitText='Send' :onSubmit='sendInvoice'>
    <template v-slot:content>
      <app-email-form
        :value='emailDefinition'
        @changed='payload => handleChange(payload)'
        template='invoice_mailout'
        :estimate='estimate'
      ></app-email-form>
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/templatedEmail';

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
      emailDefinition: null
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
        subject: this.emailDefinition.subject
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
