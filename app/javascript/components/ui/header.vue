<template>
  <div id='header-container'>
    <h5 id='title-text'>{{ title }}</h5>

    <slot name='header-right'></slot>
  </div>
</template>

<script>
export default {
  props: {
    title:{
      required: true
    }
  }
}
</script>

<style scoped>
  #title-text{
    margin: 0;
    padding: 0;
  }
  #header-container{
    padding: 8px 0;
    margin-bottom: 16px;
    border-width: 0 0 1px 0;
    border-style: solid;
    border-color: lightgray;

    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    font-size: 14px;
  }

  @media(min-width: 760px){
    #header-container{
      padding: 12px 0;
      font-size: 16px;
    }
  }
</style>
