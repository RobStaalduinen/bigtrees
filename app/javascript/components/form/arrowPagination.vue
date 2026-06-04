<template>
  <div class='pagination-control'>
    <span class='pagination-range'><b>{{ currentRange() }}</b> of {{ totalEntries }}</span>
    <div class='pagination-buttons'>
      <button type='button' class='pagination-button' @click='decreasePage()'>
        <b-icon icon='chevron-left'></b-icon>
      </button>
      <button type='button' class='pagination-button' @click='increasePage()'>
        <b-icon icon='chevron-right'></b-icon>
      </button>
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
    width: 100%;
    padding: 2px 2px;
    font-size: 14px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .pagination-range {
    color: #666;
  }

  .pagination-range b {
    color: #222;
  }

  .pagination-buttons {
    display: flex;
    gap: 6px;
  }

  .pagination-button {
    width: 30px;
    height: 22px;
    border-radius: 6px;
    border: 1px solid #c9c9c9;
    background: #fff;
    color: #444;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    font-size: 12px;
  }

  .pagination-button:active {
    border-color: var(--main-color);
    color: var(--main-color);
    background: #faf7f7;
  }
</style>
