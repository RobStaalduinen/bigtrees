<template>
  <div id="tag-list">
    <div class="tag-container" v-for="tag in tags" :key="tag.id"> 
      <app-tag :tag="tag" />
    </div>
  </div>
</template>

<script>

export default {
  props: {
    tags: {
      type: Array,
      required: true
    }
  },
}
</script>

<style scoped>
  .tag-container {
    margin-right: 4px;
    
  }

  #tag-list {
    display: flex;
    flex-wrap: wrap;
  }
</style>
