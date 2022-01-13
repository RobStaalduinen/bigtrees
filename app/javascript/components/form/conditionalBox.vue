<template>
  <div class='conditional-box'>
    <div class='conditional-header'>
      <app-checkbox-right-label
        :id='id'
        v-model='condition'
        :label='conditionName'
      />
    </div>
    <div class='conditional-body' v-if='condition'>
      <slot></slot>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    id: {
      required: true,
      type: String
    },
    conditionName: {
      required: true,
      type: String
    },
    value: {
      required: true,
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      condition: this.value
    }
  },
  watch: {
    condition() {
      this.$emit('input', this.condition)
    }
  }
}
</script>

<style>
  .conditional-box {
    border: 1px solid lightgray;
    border-radius: 5px;
    padding: 8px;
  }

  .conditional-body {
    margin-top: 8px;
  }
</style>
