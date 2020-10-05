<template>
  <div id='loading-overlay'>
    <app-loader></app-loader>
  </div>
</template>

<script>
export default {
  
}
</script>

<style scoped>
  #loading-overlay{
    z-index: 10;
    display: block;
    position: absolute;
    height: 100%;
    top: 0;
    left: 0;
    right: 0;
    background: rgba(0, 0, 0, 0.1);
  }
</style>
