<template>
  <div>
    <app-input-field
      v-model='email'
      name="email"
      label='Email'
      :disabled='lockEmail'
      validationRules='required'
    ></app-input-field>

    <app-input-field
      v-model='name'
      name="name"
      label='Name'
      validationRules='required'
    ></app-input-field>

    <app-input-field
      v-model='phone_number'
      name="phone_number"
      label='Phone Number'
      validationRules='required'
    ></app-input-field>

    <app-number-field
      v-model='hourly_rate'
      name="hourly_rate"
      label='Hourly Rate'
      v-if='hasPermission("arborists", "create")'
    ></app-number-field>

    <app-select-field
      label='Role'
      v-model='role'
      name='role'
      :options="roleOptions"
      validationRules='required'
      v-if='hasPermission("arborists", "create")'
    />
  </div>
</template>

<script>
export default {
  props: {
    value: {
      default: () => {
        return {
          name: null,
          phone_number: null,
          email: null,
          hourly_rate: null,
          role: 'arborist'
        }
      }
    },
    lockEmail: false
  },
  data() {
    return {
      name: this.value.name,
      certification: this.value.certification,
      phone_number: this.value.phone_number,
      email: this.value.email,
      hourly_rate: this.value.current_hourly_rate,
      role: this.value.role || 'arborist'
    }
  },
  computed: {
    employeeDefinition() {
      return {
        name: this.name,
        certification: this.certification,
        phone_number: this.phone_number,
        email: this.email,
        hourly_rate: this.hourly_rate,
        role: this.role
      }
    },
    roleOptions() {
      return [
        {
          value: 'arborist',
          text: 'Arborist',
        },
        {
          value: 'team_lead',
          text: 'Team Lead',
        },
        {
          value: 'mechanic',
          text: 'Mechanic',
        },
        {
          value: 'admin',
          text: 'Admin'
        }
      ]
    }
  },
  watch: {
    employeeDefinition() {
      this.$emit('input', this.employeeDefinition);
    }
  }
}
</script>

<style scoped>

</style>
