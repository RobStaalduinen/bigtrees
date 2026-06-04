<template>
  <span
    class='pill'
    :class='[`pill--${tone}`, filled ? "pill--filled" : "pill--plain", { "pill--clickable": clickable }]'
  >
    <b-icon v-if='icon' :icon='icon' class='pill-icon'></b-icon>
    <span class='pill-text'>{{ displayText }}</span>
  </span>
</template>

<script>
// Generic pill / badge primitive.
//   tone    — brand | neutral | info | success | warning | danger
//   filled  — soft tinted background (badge), vs. plain white pill
//   clickable — adds cursor + hover affordance
//   capitalize — title-cases the first letter (handy for enum values)
const TONES = ['brand', 'neutral', 'info', 'success', 'warning', 'danger'];

export default {
  props: {
    icon: { type: String, default: null },
    text: { type: [String, Number], default: '' },
    tone: {
      type: String,
      default: 'neutral',
      validator: t => TONES.includes(t)
    },
    filled: { type: Boolean, default: false },
    clickable: { type: Boolean, default: false },
    capitalize: { type: Boolean, default: false }
  },
  computed: {
    displayText() {
      const t = (this.text == null) ? '' : String(this.text);
      return this.capitalize ? t.charAt(0).toUpperCase() + t.slice(1) : t;
    }
  }
}
</script>

<style scoped>
  .pill {
    display: inline-flex;
    align-items: center;
    gap: var(--space-1);
    padding: 2px var(--space-2);
    border-radius: var(--radius-pill);
    font-size: var(--text-xs);
    font-weight: 600;
  }

  /* Plain (white) pills — tone colours the icon only */
  .pill--plain {
    background: var(--surface);
    border: 1px solid var(--border);
    color: var(--ink);
  }
  .pill--plain.pill--brand   .pill-icon { color: var(--main-color); }
  .pill--plain.pill--info    .pill-icon { color: var(--info); }
  .pill--plain.pill--success .pill-icon { color: var(--success); }
  .pill--plain.pill--warning .pill-icon { color: var(--warning); }
  .pill--plain.pill--danger  .pill-icon { color: var(--danger); }
  .pill--plain.pill--neutral .pill-icon { color: var(--neutral); }

  /* Filled (soft tinted) pills — icon inherits text colour */
  .pill--filled.pill--brand   { background: var(--color-brand-wash); color: var(--main-color); border: 1px solid #e8d6d6; }
  .pill--filled.pill--neutral { background: var(--surface-sunken);   color: var(--text);       border: 1px solid var(--border); }
  .pill--filled.pill--info    { background: #e8f0fe; color: #1a56c4; border: 1px solid #c5d8fb; }
  .pill--filled.pill--success { background: #e6f7f0; color: #0b7a55; border: 1px solid #b8e8d5; }
  .pill--filled.pill--warning { background: #fdf2e0; color: #b9740c; border: 1px solid #f3dcae; }
  .pill--filled.pill--danger  { background: #fdeaea; color: #cc2a2a; border: 1px solid #f4c3c3; }

  .pill--clickable {
    cursor: pointer;
    transition: border-color var(--transition-fast), filter var(--transition-fast);
  }
  .pill--plain.pill--clickable:hover { border-color: var(--main-color); }
  .pill--filled.pill--clickable:hover { filter: brightness(0.96); }
</style>
