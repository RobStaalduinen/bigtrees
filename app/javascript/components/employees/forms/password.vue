<template>
  <div>
    <app-input-field
      v-model='password'
      name="password"
      label='Password'
      inputType="password"
      validationRules='required'
    ></app-input-field>

    <app-input-field
      v-model='password_confirmation'
      name="password_confirmation"
      label='Password Confirmation'
      inputType="password"
      validationRules='required'
    ></app-input-field>
  </div>
</template>

<script>
export default {
  data() {
    return {
      password: null,
      password_confirmation: null
    }
  },
  computed: {
    passwordDetails() {
      return {
        password: this.password,
        password_confirmation: this.password_confirmation
      }
    }
  },
  watch: {
    passwordDetails() {
      this.$emit('input', this.passwordDetails)
    }
  }
}
</script>

<style scoped>

</style>
