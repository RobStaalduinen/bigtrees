<template>
    <app-right-sidebar-form
      :id='id'
      title='Add Expiration'
      submitText='Submit'
      :onSubmit='createExpiration'
      @cancelled='reset'
      :submitting='submitting'
    >
      <template v-slot:content>
        <validation-observer ref="observer">
          <app-select-field
            label='Name'
            v-model='name'
            name='name'
            :options="['Annual Sticker', 'Plate Sticker']"
            validationRules='required'
          />

          <app-datepicker
            v-model='date'
            locale='en-CA'
            id='date'
            name='date'
            label='Date'
            validationRules='required'
          >
          </app-datepicker>

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
  props: ['id', 'vehicle_id', 'expiration'],
  components: {
  },
  data() {
    return {
      expiration_id: null,
      date: null,
      name: 'Plate Sticker',
      submitting: false,
      errorMessage: null
    }
  },
  methods: {
    createExpiration() {
      this.errorMessage = null;
      this.submitting = true;
      this.$refs.observer.validate().then(success => {
        if (!success) {
          this.submitting = false;
          return;
        }

        this.apiCall().then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('VEHICLE_UPDATED');
          setTimeout(() => {
            this.reset();
          }, 500);
        })
      })
    },
    apiCall() {
      let params = { expiration: {
        name: this.name,
        date: this.date
      }}

      if(!this.expiration) {
        params.expiration.vehicle_id = this.vehicle_id;
        return this.axiosPost('/expirations', params);
      }
      else {
        return this.axiosPut(`/expirations/${this.expiration_id}`, params);
      }
    },
    reset() {
      this.submitting = false;
      this.name = 'Plate Sticker';
      this.date = null;
    },
  },
  watch: {
    expiration() {
      if(!this.expiration) {
        return
      }
      this.expiration_id = this.expiration.id;
      this.name = this.expiration.name;
      this.date = this.expiration.date;
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
