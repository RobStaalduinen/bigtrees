<template>
  <b-pagination
    v-model="currentPage"
    :total-rows="totalRows"
    :per-page=30
    class='pagination-control'
    align='fill'
    limit=15
  ></b-pagination>
</template>

<script>
export default {
  props: {
    totalRows: {
      type: Number
    }
  },
  data() {
    return {
      currentPage: 1,
    }
  },
  watch: {
    currentPage: function() {
      this.$emit('input', this.currentPage);
    }
  }
}
</script>

<style scoped>

  .pagination-control > li  {
    color: var(--main-color) !important;
    display: none;
  }
</style>
