<template>
  <div class='action-link' @click='handleClick'>
    {{ name }}
  </div>
</template>

<script>
export default {
  props: [ 'name', 'onClick'],
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
  }
</style>
