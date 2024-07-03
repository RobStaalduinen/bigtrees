<template>
  <div class='tree-section'>
    <div class='tree-header'>
      {{ taskHeader(index, tree)}}
    </div>

    <div v-if='tree && tree.description'>
      <b>Customer Description: </b> {{ tree.description }}
    </div>

    <div class='image-row'>
      <img
        v-for='(image, imageIndex) in images'
        :key='index + "_" + imageIndex'
        :src='image.edited_image_url_sm || image.image_url_sm'
        class='tree-image'
        @click='$emit("edit", image.id)'
      />
    </div>
  </div>
</template>

<script>


export default {
  props: {
    'index' : {
      required: true,
      type: Number
    },
    'tree': {
      required: false,
      type: Object
    },
    'images': {
      required: true,
      type: Array
    }
  },
  methods: {
    taskHeader(index, tree) {
      if (tree == null) {
        return 'Uncategorized';
      } else {
        return `Task ${index}`;
      }
    },
  }
}
</script>

<style scoped>
  .tree-section {
    margin-bottom: 8px;
  }

  .tree-header {
    font-weight: 600;
  }

  .image-row {
    display: flex;
    width: 100%;
    overflow: scroll;
  }

  .tree-image {
    max-width: 30%;
    margin-right: 8px;
  }
</style>
