<template>
  <b-form-group
  
  >
    <b-form-input v-model="value" type="text" debounce="500" class='search-field' placeholder='Search...'></b-form-input>  
  </b-form-group>
</template>

<script>
export default {
  data() {
    return {
      value: null
    }
  },
  watch: {
    value: function(){
      this.$emit('input', this.value)
    }
  }
}
</script>

<style scoped>
  .search-field{
    width: 100%;
  }
</style>
