<template>
  <span
    class='meta-pill'
    :class='[fillClass, { "meta-pill--plain": !fill, "meta-pill--clickable": clickable }]'
  >
    <b-icon
      v-if='icon'
      :icon='icon'
      class='meta-pill-icon'
      :style='iconStyle'
    ></b-icon>
    <span class='meta-pill-text'>{{ displayText }}</span>
  </span>
</template>

<script>
export default {
  props: {
    icon: {
      type: String,
      default: null
    },
    text: {
      type: [String, Number],
      default: ''
    },
    clickable: {
      type: Boolean,
      default: false
    },
    // Difficulty-style filled variant: 'easy' | 'medium' | 'hard'.
    fill: {
      type: String,
      default: null
    },
    // Icon tint for plain pills (any CSS colour, e.g. a var() or hex).
    iconColor: {
      type: String,
      default: null
    },
    // Capitalize the first letter of the text (handy for enum values).
    capitalize: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    fillClass() {
      return this.fill ? `meta-pill--fill-${this.fill}` : null;
    },
    iconStyle() {
      // Filled pills colour the icon via currentColor; plain pills can tint it.
      return (!this.fill && this.iconColor) ? { color: this.iconColor } : null;
    },
    displayText() {
      const t = (this.text == null) ? '' : String(this.text);
      return this.capitalize ? t.charAt(0).toUpperCase() + t.slice(1) : t;
    }
  }
}
</script>

<style scoped>
  .meta-pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 2px 9px;
    border-radius: 999px;
    font-size: 11.5px;
    font-weight: 600;
  }

  .meta-pill--plain {
    background: #fff;
    border: 1px solid #d8d8d8;
  }

  .meta-pill--clickable {
    cursor: pointer;
    transition: border-color 0.15s, filter 0.15s;
  }

  .meta-pill--plain.meta-pill--clickable:hover {
    border-color: var(--main-color);
  }

  .meta-pill--fill-easy.meta-pill--clickable:hover,
  .meta-pill--fill-medium.meta-pill--clickable:hover,
  .meta-pill--fill-hard.meta-pill--clickable:hover {
    filter: brightness(0.96);
  }

  .meta-pill--fill-easy   { background: #e6f7f0; color: #0b7a55; border: 1px solid #b8e8d5; }
  .meta-pill--fill-medium { background: #fdf2e0; color: #b9740c; border: 1px solid #f3dcae; }
  .meta-pill--fill-hard   { background: #fdeaea; color: #cc2a2a; border: 1px solid #f4c3c3; }
</style>
