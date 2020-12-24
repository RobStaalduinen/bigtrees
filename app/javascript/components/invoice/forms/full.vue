<template>
  <div>
      <app-input-field
        :value='value.number'
        @input="(value) => update('number', value)"
        name='number'
        label='Invoice Number'
        validationRules='required'
      ></app-input-field>

      <b-form-group
        label="Payment Method"
        label-for="payment_method"
      >
        <b-form-select
          :value='value.payment_method'
          @input="(value) => update('payment_method', value)"
          name='payment_method'
          :options="['Cheque', 'E-Transfer', 'Debit', 'Credit', 'Cash']"
          id='payment-method-select'
        />
      </b-form-group>
  </div>
</template>

<script>
export default {
  props: ['value'],
  data() {
    return {
      number: this.value.number,
      payment_method: this.value.payment_method
    }
  },
  methods: {
    update(key, value) {
      this.$emit('input', { ...this.value, [key]: value })
    }
  }
}
</script>

<style scoped>

</style>
