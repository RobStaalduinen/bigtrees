<template>
  <div>
    <div class='collapsable-header' @click='handleClick'>
      <b-icon icon='chevron-up' class='collapsable-icon' v-if='collapsed'></b-icon>
      <b-icon icon='chevron-down' class='collapsable-icon' v-if='!collapsed'></b-icon>

      {{ title }}
    </div>

    <b-collapse :id='id + "_content"' class='collapsable-body'>
      <slot name='content'></slot>
    </b-collapse>
  </div>
</template>

<script>
export default {
  props: {
    title: {
      required: true
    },
    id: {
      required: true
    }
  },
  data() {
    return {
      collapsed: true
    }
  },
  methods: {
    handleClick() {
      this.$root.$emit('bv::toggle::collapse', this.id + '_content');
      this.collapsed = !this.collapsed;
    }
  }
}
</script>

<style scoped>
  .collapsable-header {
    padding: 8px;
    font-weight: 600;
    border: 1px lightgray solid;
    display: flex;
    align-items: center;
  }

  .collapsable-icon {
    margin-right: 16px;
    font-size: 22px;
    font-weight: 600;
  }

  .collapsable-header:focus {
    outline: none !important;
  }

  .collapsable-body {
    border: 1px lightgray solid;
    border-width: 0 1px 1px 1px;
  }
</style>
