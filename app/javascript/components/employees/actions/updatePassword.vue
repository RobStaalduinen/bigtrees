<template>
    <app-right-sidebar-form
      :id='id'
      title='Update Password'
      submitText='Submit'
      :onSubmit='updatePassword'
      @cancelled='reset'
      :submitting='submitting'
    >
      <template v-slot:content>
        <validation-observer ref="observer">

          <app-password-form
            v-model='passwordDetails'
          ></app-password-form>


          <div class='error-box' v-if='errorMessage'>
            {{ errorMessage }}
          </div>
        </validation-observer>
      </template>
  </app-right-sidebar-form>
</template>

<script>
import EventBus from '@/store/eventBus';
import moment from 'moment';
import PasswordForm from '../forms/password';

export default {
  props: ['id', 'employee'],
  components: {
    'app-password-form': PasswordForm
  },
  data() {
    return {
      passwordDetails: {},
      submitting: false,
      errorMessage: null
    }
  },
  methods: {
    updatePassword() {
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
            ...this.passwordDetails
          }
        }

        this.axiosPut(`/arborists/${this.employee.id}/update_password`, params).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('DISPLAY_MESSAGE', 'Password has been successfully updated');
          setTimeout(() => {
            this.reset();
          }, 500);
        })
      })
    },
    reset() {
      this.submitting = false;
      this.passwordDetails = {};
    }
  },
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
