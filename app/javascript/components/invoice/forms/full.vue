<template>
  <div>
      <app-input-field
        :value='value.number'
        @input="(value) => update('number', value)"
        name='number'
        label='Invoice Number'
        validationRules='required'
      ></app-input-field>

      <app-select-field
        label='Payment Method'
        :value='value.payment_method'
        @input="(value) => update('payment_method', value)"
        name='payment_method'
        :options="['Cheque', 'E-Transfer', 'Debit', 'Credit', 'Cash']"
      />
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
    },
    getValidationState({ dirty, validated, valid = null }) {
      return !valid && (dirty || validated) ? valid : null;
    }
  }
}
</script>

<style scoped>

</style>
