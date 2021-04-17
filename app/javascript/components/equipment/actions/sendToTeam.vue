<template>
  <app-right-sidebar :id='id' title='Send Equpment Request' submitText='Send' :onSubmit='sendEquipmentRequest'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-email-form :value='emailDefinition' @changed='payload => handleChange(payload)'></app-email-form>

        <div class='error-box' v-if='errorMessage'>
          {{ errorMessage }}
        </div>
      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/emailArboristSelect';
import { repairRequest } from '../../../content/emailContent';
import EventBus from '@/store/eventBus'
import { EmailDefinition } from '@/models';

export default {
  components: {
    'app-email-form': EmailForm
  },
  props: {
    id: {
      required: true
    },
    equipmentRequest: {
      required: true
    }
  },
  data() {
    return {
      emailDefinition: null,
      errorMessage: null
    }
  },
  methods: {
    handleChange(new_email) {
      this.emailDefinition = { ...new_email }
    },
    sendEquipmentRequest() {
      this.errorMessage = null;

      if(this.emailDefinition.email.length == 0) {
        this.errorMessage = 'Please enter at least one recipient';
        EventBus.$emit('FORM_VALIDATION_FAILED');
        return;
      }

      var params = {
        dest_email: this.emailDefinition.email,
        content: this.emailDefinition.content,
        subject: this.emailDefinition.subject
      }
      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return
        }
        else {
          this.axiosPost(`/equipment_requests/${this.equipmentRequest.id}/send_mailout`, params).then(response => {
            this.$root.$emit('bv::toggle::collapse', this.id);
          })
        }
      })
    }
  },
  watch: {
    equipmentRequest: {
      immediate: true,
      handler() {

        if(this.equipmentRequest != null) {
          let content = repairRequest;
          content += `Type: ${this.equipmentRequest.category} \n`
          if(this.equipmentRequest.vehicle){
            content += `Vehicle: ${this.equipmentRequest.vehicle.name} \n`
          }
          content += `Description: ${this.equipmentRequest.description} \n`

          this.emailDefinition = new EmailDefinition(
            null,
            'New Repair Request',
            content
          )
        }
      }
    }
  }
}
</script>
