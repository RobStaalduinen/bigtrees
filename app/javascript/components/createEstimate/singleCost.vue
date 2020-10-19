<template>
  <div>
    
    <div class='single-cost-top-row'>
      <div id='single-cost-amount'>
        <app-input-field
          v-model='cost.amount'
          name='amount'
          label='Amount'
          validationRules='required'
          inputType='number'
        ></app-input-field>
      </div>

      <b-icon icon='trash-fill' class='icon' @click='emitDelete' v-if='displayDelete'></b-icon>
    </div>

    <app-input-field
      v-model='cost.description'
      name='description'
      label='Description'
      validationRules='required'
      :maxLength='65'
    ></app-input-field>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      default: () => { return { amount: null, description: null } }
    },
    index: {
      required: true,
      type: Number
    },
    displayDelete: {
      type: Boolean
    }
  },
  data() {
    return {
      cost: this.value
    }
  },
  watch: {
    cost: function() {
      this.$emit('input', this.cost);
    }
  },
  methods: {
    emitDelete() {
      console.log("DELETE EMITTED");
      this.$emit('deleted', this.index);
    }
  }
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
</style>
