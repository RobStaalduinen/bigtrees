<template>
    <app-right-sidebar-form
      :id='id'
      title='Create Equipment'
      submitText='Submit'
      :onSubmit='createVehicle'
      @cancelled='reset'
      :submitting='submitting'
    >
      <template v-slot:content>
        <validation-observer ref="observer">
          <app-input-field
            v-model='name'
            name="name"
            label='Name'
            validationRules='required'
          ></app-input-field>

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

import { stringOptionList, objectOptionList } from '@/utils/formUtils';

export default {
  props: ['id'],
  components: {
  },
  data() {
    return {
      name: null,
      submitting: false,
      errorMessage: null
    }
  },
  methods: {
    createVehicle() {
      this.errorMessage = null;
      this.submitting = true;
      this.$refs.observer.validate().then(success => {
        if (!success) {
          this.submitting = false;
          return;
        }

        let params = { vehicle: {
          name: this.name
        }}

        this.axiosPost('/vehicles', params).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('VEHICLE_UPDATED');
          setTimeout(() => {
            this.reset();
          }, 500);
        })
      })
    },
    reset() {
      this.submitting = false;
      this.name = null;
    }
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
