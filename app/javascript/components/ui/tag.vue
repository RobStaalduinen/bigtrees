<template>
  <div class='tag' :style="{ backgroundColor: colorCode }">
    <slot></slot>
  </div>
</template>

<script>
export default {
  props: {
    color: {
      type: String,
      default: 'white'
    }
  },
  data() {
    return {

    }
  },
  computed: {
    colorCode() {
      if (this.color === 'yellow') {
        return '#c9b91e';
      }
    }
  },
  methods: {

  },
  watch: {

  }
}
</script>

<style scoped>
  .tag {
    color: white;
    padding: 2px 4px;
    border-radius: 4px;
    display: inline-block;

    font-weight: 700;
  }

  .tag-yellow {
    background-color: #FFD700;
  }
</style>
