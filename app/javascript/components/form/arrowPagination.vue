<template>
  <div class='pagination-control'>
    {{ currentRange() }} of {{ totalEntries }}
    <div class='pagination-buttons'>
      <b-icon icon='chevron-left' class='pagination-button' @click='decreasePage()'></b-icon>
      <b-icon icon='chevron-right' class='pagination-button' @click='increasePage()'></b-icon>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    totalEntries: {
      type: Number
    },
    perPage: {
      type: Number,
      default: 10
    },
    value: {
      required: true
    }
  },
  data() {
    return {
      currentPage: this.value
    }
  },
  watch: {
    currentPage: function() {
      this.$emit('input', this.currentPage);
    },
    value: function() {
      this.currentPage = this.value;
    }
  },
  methods: {
    currentRange() {
      var min = ((this.currentPage - 1) * this.perPage) + 1;
      var max = Math.min(this.currentPage * this.perPage, this.totalEntries);

      return `${min} - ${max}`
    },
    decreasePage() {
      if(this.currentPage > 1) {
        this.currentPage -= 1;
      }
    },
    increasePage() {
      var newPage = this.currentPage + 1;
      if ((this.currentPage * this.perPage) <= this.totalEntries) {
        this.currentPage += 1;
      } 
    }
  }
}
</script>

<style scoped>
  .pagination-control {
    background-color: #eeeeee;
    width: 100%;
    padding: 6px;
    font-size: 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .pagination-buttons {
    display: flex;
  }

  .pagination-button {
    margin: 0 16px;
  }
</style>
