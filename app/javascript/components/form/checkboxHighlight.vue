<template>
  <label :for="id" :class="{'checkbox-container': true,  'checkbox-container-faded': status != checkedValue }">
    <b-form-checkbox
      :id="id"
      v-model="status"
      :name="id"
      :value="checkedValue"
      :unchecked-value="uncheckedValue"
    >
      {{ label }}
    </b-form-checkbox>
  </label>
</template>

<script>
export default {
  props: {
    value: {

    },
    checkedValue: {

    },
    uncheckedValue: {
      default: null
    },
    initialStatus: {
      type: Boolean,
      default: false
    },
    label: {
      type: String,
      required: true
    },
    id: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      status: this.value
    }
  },
  methods: {
    currentValue() {
      if(this.status) {
        return this.checkedValue;
      }
      return this.uncheckedValue

    }
  },
  watch: {
    status() {
      this.$emit('input', this.status);
    }
  },
  mounted() {
    console.log(this.status);
    console.log(this.checkedValue);
    console.log(this.status == this.checkedValue);
  }

}
</script>

<style scoped>
  .checkbox-container {
    display: flex;
    align-items: center;
    padding: 8px 16px;

    border: 1px solid lightgray;
  }

  .checkbox-container-faded {
    opacity: 0.5;
  }
</style>
