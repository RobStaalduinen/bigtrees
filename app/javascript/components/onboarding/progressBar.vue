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
    height: 10px;
    width: 100%;
    background-color: #eeeeee;
  }

  #progress-internal {
    background-color: var(--main-color);
    transition: width 0.5s;
    height: 100%;
  }
</style>
