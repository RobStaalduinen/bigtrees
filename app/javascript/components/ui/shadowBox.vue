<template>
  <div class='box-element'>
    <div class='box-header'>
      <slot name='box-header'></slot>
    </div>

    <slot name='box-body'></slot>
  </div>
</template>

<style scoped>
  .box-element {
    border: 1px solid lightgray;
    box-shadow: 0 5px 3px -3px rgba(153, 153, 153, 0.5);
  }
  
  .box-header {
    padding: 8px;
    border-width: 0 0 2px 0;
    border-color: lightgray;
    border-style: solid;
    margin-bottom: 8px;
  }

  .box-header > h4, h5 {
    margin-bottom: 0;
  }
</style>
