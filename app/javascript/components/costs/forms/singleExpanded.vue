<template>
  <div id='cost-row'>
    <div id='cost-row-top'>
      <app-number-field
        v-model='cost.amount'
        :name='baseName + "_amount"'
        label='Amount'
        validationRules='required'
      ></app-number-field>
    </div>

    <div id='cost-row-botton'>
      <app-text-area
        v-model='cost.description'
        :name='baseName + "_description"'
        label='Invoice Description'
        validationRules='required'
        :maxLength='65'
        :noResize='true'
      ></app-text-area>
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
    },
  }
}
</script>

<style scoped>
  .single-cost-top-row {
    display: flex;
  }

  #cost-row{
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    margin-top: 4px;
  }

  #cost-row-left{
    width: 100%;
  }

  #cost-row-right{
    width: 100%;
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
</style>
