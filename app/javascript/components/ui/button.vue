<template>
  <button
    type="button"
    :class="['ui-btn', `ui-btn--${variant}`, `ui-btn--${size}`, { 'ui-btn--icon-only': !hasText }]"
    :title="label"
    :aria-label="label"
    @click='handleClick'
  >
    <b-icon :icon="icon" v-if="icon != null" class='ui-btn-icon'></b-icon>
    <span v-if="hasText" class="ui-btn-text">{{ text }}</span>
  </button>
</template>

<script>
export default {
  props: {
    text: {
      type: String,
      default: null
    },
    icon: {
      type: String,
      default: null
    },
    click: {
      type: Function,
      required: false
    },
    // default (legacy grey) | primary | outline | subtle | ghost
    variant: {
      type: String,
      default: 'default'
    },
    // sm | md
    size: {
      type: String,
      default: 'md'
    },
    // aria-label / title — important for icon-only buttons
    label: {
      type: String,
      default: null
    }
  },
  computed: {
    hasText() {
      return this.text !== null && this.text !== '';
    }
  },
  methods: {
    handleClick() {
      if (this.click) {
        this.click();
      }
    }
  }
}
</script>

<style scoped>
  .ui-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: var(--space-1);
    cursor: pointer;
    font-weight: 600;
    border: 1px solid transparent;
    border-radius: var(--radius-md);
    white-space: nowrap;
  }

  /* Sizes (apply to all but the legacy default variant, which sets its own) */
  .ui-btn--sm { padding: 4px 9px; font-size: 12.5px; }
  .ui-btn--md { padding: 7px 12px; font-size: 13.5px; }

  .ui-btn--icon-only.ui-btn--sm { padding: 5px 7px; font-size: 14px; }
  .ui-btn--icon-only.ui-btn--md { padding: 7px 10px; font-size: 16px; }

  /* Variants — declared after sizes so the default variant's padding wins */
  .ui-btn--default {
    background-color: #eeeeee;
    border-color: gray;
    color: #212529;
    border-radius: 5px;
    font-size: 14px;
    font-weight: 400;
    padding: 1px 10px;
  }

  .ui-btn--primary {
    background-color: var(--main-color);
    border-color: var(--main-color);
    color: #fff;
  }
  .ui-btn--primary:hover { background-color: var(--main-color-faded); }

  .ui-btn--outline {
    background-color: var(--surface);
    border-color: var(--main-color);
    color: var(--main-color);
  }
  .ui-btn--outline:hover { background-color: var(--color-brand-wash); }

  .ui-btn--subtle {
    background-color: var(--surface);
    border-color: #d6d6d6;
    color: var(--text);
  }
  .ui-btn--subtle:hover { background-color: var(--surface-sunken); color: var(--ink); }

  .ui-btn--ghost {
    background-color: transparent;
    border-color: transparent;
    color: var(--text-muted);
  }
  .ui-btn--ghost:hover { background-color: var(--surface-sunken); color: var(--text); }
</style>
