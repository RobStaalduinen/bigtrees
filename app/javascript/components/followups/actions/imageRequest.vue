<template>
  <app-right-sidebar :id='id' title='Send Image Request' submitText='Send' :onSubmit='sendImageRequest'>
    <template v-slot:content>
      <app-email-form
        :value='emailDefinition'
        @changed='payload => handleChange(payload)'
        template='image_request'
        :estimate='estimate'
      ></app-email-form>
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/templatedEmail';
import moment from 'moment';
import EventBus from '@/store/eventBus';
import { EmailDefinition } from '@/models';

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
    sendImageRequest() {
      var params = {
        dest_email: this.emailDefinition.email,
        content: this.emailDefinition.content,
        subject: this.emailDefinition.subject,
        picture_request_sent_at: moment().format('YYYY-MM-DD'),
        include_quote: false
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
