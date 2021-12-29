<template>
  <div class='checkbox-container'>
    <b-form-checkbox
      :id="id"
      v-model="checked"
      :name="id"
      :value='true'
      :unchecked-value='false'
      class='checkbox'
    >
      <div class='checkbox-label'>{{ label }}</div>
    </b-form-checkbox>
  </div>
</template>

<script>
export default {
  props: {
    label: {
      required: true,
      type: String
    },
    id: {
      required: true,
      type: String
    },
    value: {
      required: true,
      type: Boolean
    }
  },
  data() {
    return {
      checked: this.value
    }
  },
  watch: {
    checked() {
      this.$emit('input', this.checked);
    }
  }
}
</script>

<style scoped>
  .checkbox-container {
    display: flex;
    align-items: center;
    cursor: pointer;
  }

  .checkbox-label {
    font-weight: 600;
    margin-left: 8px;
    cursor: pointer
  }

  .checkbox {
    cursor: pointer;
  }
</style>
