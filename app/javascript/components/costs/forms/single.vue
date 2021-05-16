<template>
  <div id='cost-row'>
    <div id='cost-row-left'>
      <app-input-field
        v-model='cost.amount'
        :name='baseName + "_amount"'
        label='Amount'
        validationRules='required'
        inputType='number'
      ></app-input-field>
    </div>

    <div id='cost-row-right'>
      <app-input-field
        v-model='cost.description'
        :name='baseName + "_description"'
        label='Invoice Description'
        validationRules='required'
        :maxLength='65'
      ></app-input-field>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      default: () => { return { amount: null, description: null } }
    },
    baseName: {
      required: false,
      default: 'cost'
    }
  },
  data() {
    return {
      cost: this.value
    }
  },
  computed: {
    costValue() {
      return { ...this.cost }
    }
  },
  watch: {
    costValue: function() {
      this.$emit('input', this.costValue);
    }
  },
}
</script>

<style scoped>
  .single-cost-top-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  #single-cost-amount {
    width: 80%;
  }

  .icon {
    color: var(--main-color);
    font-size: 22px;
    margin-right: 8px;
    cursor: pointer;
  }

  #cost-row{
    display: flex;
    justify-content: space-between;
    margin-top: 16px;
  }

  #cost-row-left{
    width: 30%;
  }

  #cost-row-right{
    width: 68%;
  }
</style>
