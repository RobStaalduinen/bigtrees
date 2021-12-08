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
            v-if='employeeDefinition'
            v-model='employeeDefinition'
          ></app-employee-form>


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

import { stringOptionList, objectOptionList } from '@/utils/formUtils';

export default {
  props: ['id', 'employee'],
  components: {
    'app-employee-form': EmployeeForm
  },
  data() {
    return {
      name: null,
      submitting: false,
      errorMessage: null,
      employeeDefinition: { ...this.employee },
    }
  },
  methods: {
    createEmployee() {
      this.errorMessage = null;
      this.submitting = true;

      this.$refs.observer.validate().then(success => {
        if (!success) {
          this.submitting = false;
          return;
        }

        let params = {
          arborist: {
            ...this.employeeDefinition
          }
        }

        this.axiosPut(`/arborists/${this.employee.id}`, params).then(response => {
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
      this.employeeDefinition = {};
    }
  },
  watch: {
    employee() {
      this.employeeDefinition = { ...this.employee }
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
