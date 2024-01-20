<template>
  <app-right-sidebar :id='id' title='Send Followup' submitText='Send' :onSubmit='sendNoResponseRequest' :alternateAction='skipSend'>
    <template v-slot:content>
      <app-email-form
        :value='emailDefinition'
        @changed='payload => handleChange(payload)'
        template="no_response"
        :estimate='estimate'
      ></app-email-form>
    </template>
  </app-right-sidebar>
</template>

<script>
import TemplatedEmailForm from '../../common/forms/templatedEmail.vue';
import moment from 'moment';
import EventBus from '@/store/eventBus';
import { EmailDefinition } from '@/models';
export default {
  components: {
    'app-email-form': TemplatedEmailForm
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
    skipSend(){
      this.sendNoResponseRequest(true);
    },
    sendNoResponseRequest(skip = false) {
      var params = {
        dest_email: this.emailDefinition.email,
        content: this.emailDefinition.content,
        subject: this.emailDefinition.subject,
        followup_sent_at: moment().format('YYYY-MM-DD'),
        include_quote: true,
        skip: skip
      }
      this.axiosPost(`/estimates/${this.estimate.id}/followups`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
      })
    }
  }
}
</script>

<style scoped>

</style>
