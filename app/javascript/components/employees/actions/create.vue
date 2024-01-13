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

          <div class='error-box' v-if='errorMessage'>
            {{ errorMessage }}
          </div>
        </validation-observer>
      </template>
  </app-right-sidebar-form>
</template>

<script>
import EventBus from '@/store/eventBus';
import EmployeeForm from '../forms/single';

export default {
  props: ['id'],
  components: {
    'app-employee-form': EmployeeForm
  },
  data() {
    return {
      name: null,
      submitting: false,
      errorMessage: null,
      employee: {}
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
            ...this.employee
          }
        }

        this.axiosPost('/arborists', params).then(response => {

          if(response.status == 200) {
            if(response.data.meta.existing_user == true) {
              EventBus.$emit('DISPLAY_MESSAGE', 'Employee has been successfully added. As they are an existing employee of another organization, their login details will remain the same.');
            }
            this.$root.$emit('bv::toggle::collapse', this.id);
            EventBus.$emit('EMPLOYEE_UPDATED');
            setTimeout(() => {
              this.reset();
            }, 500);
          }
        }).catch(error => {
          if(error.response.data.code == 'existing-arborist') {
            this.errorMessage = "An employee for the given email already exists as part of your company"
          }
          this.submitting = false;
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
