<template>
  <div class='segmented'>
    <button
      v-for='opt in options'
      :key='opt.value'
      type='button'
      :class='{ on: value === opt.value }'
      :disabled='opt.disabled'
      @click='select(opt.value)'
    >{{ opt.text }}</button>
  </div>
</template>

<script>
// Segmented pill control for small, mutually-exclusive option sets.
//   v-model binds the selected value.
//   options: [{ value, text }]
export default {
  props: {
    value: {
      required: true
    },
    options: {
      type: Array,
      required: true
    }
  },
  methods: {
    select(value) {
      this.$emit('input', value);
    }
  }
}
</script>

<style scoped>
  .segmented {
    display: inline-flex;
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    overflow: hidden;
    background: var(--surface-alt);
  }

  .segmented button {
    border: none;
    background: transparent;
    padding: 5px 11px;
    font-size: 12.5px;
    cursor: pointer;
    color: var(--text);
    border-left: 1px solid var(--border);
    white-space: nowrap;
  }

  .segmented button:first-child {
    border-left: none;
  }

  .segmented button.on {
    background: var(--main-color);
    color: #fff;
    font-weight: 600;
  }

  .segmented button:disabled {
    color: var(--neutral);
    cursor: not-allowed;
  }
</style>
