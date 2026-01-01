<template>
  <section>
    <app-collapsable-list-item :id='`employee-${employee.id}`' class='employee'>
      <template v-slot:content>
        <div class='list-item-header'>
          <div class='list-item-header-left'>
            <b>{{ employee.name }}</b> <span v-if='employee.certification'> {{ ` | Cert: ${employee.certification}` }}</span>
          </div>
        </div>

        <div class='list-item-content'>
          <div class='contact-row'>
            <b>Hourly Rate: </b>
            <span v-if='employee.current_hourly_rate'>{{ `$${employee.current_hourly_rate}` }}</span>
            <span v-else>Not Entered</span>
          </div>

          <div class='contact-row'>
            <b-icon icon='telephone' class='app-icon contact-icon'></b-icon>
            <a :href="'tel:' + employee.phone_number">{{ employee.phone_number }}</a>
          </div>

          <div class='contact-row'>
            <b-icon icon='envelope' class='app-icon contact-icon'></b-icon>
            <a :href="'mailto:' + employee.email">{{ employee.email }}</a>
          </div>
        </div>
      </template>

      <template v-slot:collapsed>
        <app-collapsable-action-bar>
          <template v-slot:content>
            <app-action-bar-item
              name='View Profile'
              icon='binoculars'
              :onClick='viewProfile'
            />
            <app-action-bar-item
              name='Edit'
              icon='pencil-square'
              :onClick='editEmployee'
            />
            <app-action-bar-item
              name='Reset Password'
              icon='key'
              :onClick='resetPassword'
            />

            <app-action-bar-item
              name='Remove'
              icon='trash-fill'
              :onClick='removeEmployee'
              v-if="employee.role != 'admin' && employee.role != 'super_admin'"
            />
          </template>
        </app-collapsable-action-bar>
      </template>
    </app-collapsable-list-item>
  </section>
</template>

<script>
import EventBus from '@/store/eventBus';
// import { standardDate } from '@/utils/dateUtils';

export default {
  props: {
    employee: {
      type: Object,
      required: true
    }
  },
  methods: {
    viewProfile() {
      this.$router.push(`/admin/users/${this.employee.id}`);
    },
    editEmployee() {
      EventBus.$emit('EDIT_EMPLOYEE', this.employee);
    },
    removeEmployee() {
      confirm("Are you sure you want to remove this employee from your company?")
      EventBus.$emit('REMOVE_EMPLOYEE', this.employee);
    },
    resetPassword() {
      if(!confirm("Are you sure you want to reset this employee's password?")) {
        return;
      }
      const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
      let password = "";
      for (let i = 0; i < 10; i++) {
        password += chars.charAt(Math.floor(Math.random() * chars.length));
      }

      this.axiosPut(`/arborists/${this.employee.id}/update_password`, { password: password }).then(response => {
        alert(`Password for ${this.employee.name} reset to: ${password}`);
      })
    }
  }
}
</script>

<style scoped>
  .employee {
    font-size: 12px
  }

  .single-expiration {
    display: flex;
    align-items: center;
    margin-top: 6px;
    margin-bottom: 6px;
  }

  .contact-icon {
    margin-right: 4px;
  }

  .contact-row {
    margin-top: 2px;
    margin-bottom: 2px
  }
</style>
