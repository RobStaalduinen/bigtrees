<template>
  <div class="search-wrap">
    <b-icon icon="search" class="search-icon"></b-icon>
    <b-form-input
      v-bind:value="value"
      v-model='searchTerm'
      type="text"
      debounce="500"
      class='search-field'
      placeholder='Search...'>
    </b-form-input>
  </div>
</template>

<script>
export default {
  props: ['value'],
  data() {
    return {
      searchTerm: this.value
    }
  },
  watch: {
    searchTerm: function(){
      this.$emit("input", this.searchTerm);
    },
    value: function() {
      this.searchTerm = this.value;
    }
  }
}
</script>

<style scoped>
  .search-wrap {
    position: relative;
    width: 100%;
  }

  .search-icon {
    position: absolute;
    left: 11px;
    top: 50%;
    transform: translateY(-50%);
    color: #999;
    pointer-events: none;
    z-index: 2;
  }

  .search-field {
    width: 100%;
    padding-left: 32px;
    border-radius: 9px;
    background: #fcfcfc;
  }

  .search-field:focus {
    background: #fff;
    border-color: var(--main-color);
    box-shadow: 0 0 0 3px rgba(138, 0, 0, 0.08);
  }
</style>
