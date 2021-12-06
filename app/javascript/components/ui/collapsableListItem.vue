<template>
    <div class='collapsable-item shadow-box-entry'>
      <div class='collapsable-item-body'>

        <div class='collapsable-item-content'>
          <slot name='content'></slot>
        </div>


        <div class='collapsable-control' @click='handleClick'>
          <b-icon icon='chevron-up' class='collapsable-icon' v-if='collapsed'></b-icon>
          <b-icon icon='chevron-down' class='collapsable-icon' v-if='!collapsed'></b-icon>
        </div>
      </div>

      <b-collapse :id='id + "_collapsed"' class='collapsable-item-bottom'>
        <slot name='collapsed'></slot>
      </b-collapse>
    </div>
</template>

<script>
export default {
  props: {
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
      this.$root.$emit('bv::toggle::collapse', this.id + '_collapsed');
      this.collapsed = !this.collapsed;
    }
  }
}
</script>

<style scoped>
  .collapsable-item {
    border: 1px lightgray solid;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .collapsable-item-body {
    display: flex;
    justify-content: space-between;
    width: 100%;
  }

  .collapsable-item-content {
    width: 100%;
  }

  .collapsable-control {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 10%;
    border-left-width: 1px;
    border-color: lightgray;
    border-left-style: solid;
    padding: 4px;
    max-width: 40px;

    cursor: pointer;
  }

  .collapsable-icon {
    font-size: 22px;
    font-weight: 600;
  }

  .collapsable-item-bottom {
    width: 100%;
    border-width: 1px 0 0 0;
    border-style: solid;
    border-color: lightgray;
  }
</style>
