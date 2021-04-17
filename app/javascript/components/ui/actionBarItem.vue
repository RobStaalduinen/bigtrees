<template>
  <div class='action-link' @click='handleClick'>
    {{ name }}

    <b-icon
      v-if='icon'
      class='action-icon'
      :icon='icon'
    />
  </div>
</template>

<script>
export default {
  props: [ 'name', 'onClick', 'icon'],
  methods: {
    handleClick() {
      if(!this.onClick) {
        return;
      }

      this.onClick();
    }
  }
}
</script>

<style scoped>
  .action-link {
    padding: 6px 12px;
    border-width: 0 0 0 1px;
    border-color: lightgray;
    border-style: solid;

    cursor: pointer;
    color: var(--main-color);

    display: flex;
    justify-content: center;
    align-items: center;
  }

  .action-icon {
    margin-left: 4px;
    color: var(--main-color);
  }
</style>
