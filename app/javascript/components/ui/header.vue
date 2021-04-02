<template>
  <div id='header-container'>
    <div id='header-left'>
      <slot name='header-left'>
        <div id='back-icon' v-if='shouldDisplayBack'>
          <router-link :to="backLink">
            <b-icon id='back-icon' icon='arrow-left-short'></b-icon>
          </router-link>
        </div>
        <h5 id='title-text'>{{ title }}</h5>
      </slot>
    </div>
    <slot name='header-right'></slot>
  </div>
</template>

<script>
export default {
  props: {
    title:{
      required: false
    },
    backLink: {
      required: false,
      default: null
    }
  },
  computed: {
    shouldDisplayBack() {
      return this.backLink != null
    }
  }
}
</script>

<style scoped>
  #back-icon {
    font-size: 36px;
    line-height: 36px;
    padding-right: 8px;
    cursor: pointer;
  }
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

  #header-left {
    display: flex;
    align-items: center;
  }

  @media(min-width: 760px){
    #header-container{
      padding: 12px 0;
      font-size: 16px;
    }
  }
</style>
