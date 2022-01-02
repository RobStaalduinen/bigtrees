<template>
    <app-right-sidebar-form
      :id='id'
      title='Assign Request'
      submitText='Submit'
      :onSubmit='assignRequest'
      @cancelled='reset'
      :submitting='submitting'
    >
      <template v-slot:content>
        <validation-observer ref="observer">
          <app-select-field
            label='Mechanic'
            v-model='mechanic_id'
            name='mechanic_id'
            :options="mechanicOptions"
            validationRules='required'
          />

          <app-checkbox-right-label
            id='send-email'
            v-model='sendEmail'
            label='Send Email'
          />

          <app-email-content
            v-if='sendEmail'
            v-model='emailDefinition'
            :initialContent='initialContent'
            :initialSubject='initialSubject'
          />

          <div class='error-box' v-if='errorMessage'>
            {{ errorMessage }}
          </div>
        </validation-observer>
      </template>
  </app-right-sidebar-form>
</template>

<script>
import FileUpload from '@/components/file/actions/upload';
import EventBus from '@/store/eventBus';
import moment from 'moment';
import { repairRequest } from '@/content/emailContent';

import { stringOptionList, objectOptionList } from '@/utils/formUtils';

export default {
  props: ['id', 'equipmentRequest'],
  data() {
    return {
      mechanic_id: null,
      sendEmail: true,
      emailDefinition: {},
      submitting: false,
      errorMessage: null,
      mechanics: [],
      mechanicOptions: [],
      initialContent: repairRequest,
      initialSubject: 'New Repair Request'
    }
  },
  methods: {
    assignRequest() {
      this.errorMessage = null;
      this.submitting = true;
      this.$refs.observer.validate().then(success => {
        if (!success) {
          this.submitting = false;
          return;
        }

        let params = {
          mechanic_id: this.mechanic_id
        }

        this.axiosPost(`/equipment_requests/${this.equipmentRequest.id}/assign`, params).then(response => {
          this.sendMechanicEmail().then(response => {
              this.$root.$emit('bv::toggle::collapse', this.id);
              EventBus.$emit('EQUIPMENT_REQUEST_UPDATED');
              setTimeout(() => {
                this.reset();
              }, 500);
            })
          })
      })
    },
    sendMechanicEmail() {
      let selectedMechanic = this.mechanics.filter((mechanic) => mechanic.id == this.mechanic_id)[0];

      let params = {
        dest_email: selectedMechanic.email,
        content: this.emailDefinition.body,
        subject: this.emailDefinition.subject
      }

      return this.axiosPost(`/equipment_requests/${this.equipmentRequest.id}/send_mailout`, params);
    },
    reset() {
      this.submitting = false;
      this.mechanic_id = null;
    },
    retreiveMechanics() {
      this.axiosGet('/arborists').then(response => {
        this.mechanics = response.data.arborists;
        this.setMechanicOptions();
      })
    },
    setMechanicOptions() {
      this.mechanicOptions = this.mechanics.map(mechanic => {
        return {
          value: mechanic.id,
          text: mechanic.name
        }
      })
      if(this.mechanicOptions.length > 0) {
        this.mechanic_id = this.mechanicOptions[0].value
      }
    }
  },
  mounted() {
    this.retreiveMechanics();
  }
}
</script>

<style scoped>
  #form-container {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 100%;
  }
</style>
