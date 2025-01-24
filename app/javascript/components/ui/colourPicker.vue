<template>
  <div>
    <chrome-picker :value="color" @input="updateColor" />
  </div>
</template>

<script>
import { Chrome } from 'vue-color';

export default {
  components: {
    'chrome-picker': Chrome
  },
  props: {
    value: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      color: this.value || '#000000'
    };
  },
  methods: {
    updateColor(newColor) {
      this.color = newColor.hex;
      this.$emit('input', this.color);
    }
  }
};
</script>
