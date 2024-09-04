<template>
  <div class='tree-section'>
    <div class='tree-header-section'>
      <div class='tree-header'>
        {{ taskHeader(index, tree)}}
      </div>

      <div v-if='tree' class='tree-description'>
        {{ tree.description || 'No Description' }}
      </div>
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
  },
  mounted() {
    console.log("TREE")
    console.log(this.tree);
    console.log("IMAGES")
    console.log(this.images);
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

  .tree-header-section {
    margin-bottom: 8px;
  }

  .tree-description {

    font-size: 14px;
  }

  .description-header {
    font-size: 16px;
  }

  .image-row {
    display: flex;
    width: 100%;
    overflow: scroll;
    padding-bottom: 8px;
    border-width: 0 0 1px 0;
    border-color: grey;
    border-style: solid;
  }

  .tree-image {
    max-width: 30%;
    margin-right: 8px;
  }
</style>
