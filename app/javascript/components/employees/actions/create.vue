<template>
    <app-right-sidebar-form
      :id='id'
      title='Create Employee'
      submitText='Submit'
      :onSubmit='createEmployee'
      @cancelled='reset'
      :submitting='submitting'
    >
      <template v-slot:content>
        <validation-observer ref="observer">

          <app-employee-form
            v-model='employee'
          ></app-employee-form>

          <app-employee-password-form
            v-model='passwordDetails'
          ></app-employee-password-form>


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
import EmployeeForm from '../forms/single';
import PasswordForm from '../forms/password';

import { stringOptionList, objectOptionList } from '@/utils/formUtils';

export default {
  props: ['id'],
  components: {
    'app-employee-form': EmployeeForm,
    'app-employee-password-form': PasswordForm
  },
  data() {
    return {
      name: null,
      submitting: false,
      errorMessage: null,
      employee: {},
      passwordDetails: {}
    }
  },
  methods: {
    createEmployee() {
      this.errorMessage = null;
      this.submitting = true;

      if(this.passwordDetails.password != this.passwordDetails.password_confirmation) {
        this.errorMessage = 'Password and confirmation do not match';
        this.submitting = false;
        return;
      }

      this.$refs.observer.validate().then(success => {
        if (!success) {
          this.submitting = false;
          return;
        }

        let params = {
          arborist: {
            ...this.employee,
            ...this.passwordDetails
          }
        }

        this.axiosPost('/arborists', params).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('EMPLOYEE_UPDATED');
          setTimeout(() => {
            this.reset();
          }, 500);
        })
      })
    },
    reset() {
      this.submitting = false;
      this.employee = {};
    },
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
