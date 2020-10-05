<template>

  <b-form-input 
    v-bind:value="value"
    v-model='searchTerm'
    type="text"
    debounce="500"
    class='search-field'
    placeholder='Search...'>
  </b-form-input>  

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
  },
  mounted(){
    console.log(this.searchTerm);
  }
}
</script>

<style scoped>
  .search-field{
    width: 100%;
  }
</style>
