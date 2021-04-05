<template>
  <div class='action-bar'>
    <slot name='content'></slot>
  </div>
</template>

<style scoped>
  .action-bar {
    display: flex;
    justify-content: flex-end;
  }
</style>
