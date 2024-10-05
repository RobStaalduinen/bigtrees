<template>
  <div id='progress-external'>
    <div id='progress-internal' :style="{ width: percentWidth + '%' }">

    </div>
  </div>
</template>

<script>
export default {
  props: ['percentage'],
  data() {
    return {
      percentWidth: this.percentage
    }
  },
  watch: {
    percentage() {
      this.percentWidth = this.percentage;
    }
  }
}
</script>

<style scoped>
  #progress-external {
    height: 15px;
    width: 100%;
    background-color: #eeeeee;
  }

  #progress-internal {
    background-color: var(--main-color);
    transition: width 0.5s;
    height: 100%;
  }

  @media(max-width: 759px) {
    #progress-external {
      border-width: 2px 0 0 0;
      border-style: solid;
      border-color: grey;
    }
  }
</style>
