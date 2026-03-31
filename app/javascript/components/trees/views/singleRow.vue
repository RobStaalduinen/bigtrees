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

    <div class='image-row' :class="{ 'drop-zone--active': isDragging }">
      <slot name='images' />
      <p v-if='isDragging && !hasImages' class='drop-hint'>Drop here</p>
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
    'isDragging': {
      required: false,
      type: Boolean,
      default: false
    },
    'hasImages': {
      required: false,
      type: Boolean,
      default: false
    },
  },
  methods: {
    taskHeader(index, tree) {
      let header = ""
      if (tree == null) {
        header = 'Uncategorized';
      } else {
        header = `Task ${index} - ${this.tree.work_name}`;
      }

      return header
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
    width: 100%;
    padding-bottom: 8px;
    border-width: 0 0 1px 0;
    border-color: grey;
    border-style: solid;
    min-height: 40px;
    transition: border-color 0.15s, min-height 0.15s;
  }

  .drop-zone--active {
    border: 2px dashed #4a90d9;
    border-radius: 4px;
    min-height: 80px;
  }


  .drop-hint {
    color: #9b9b9b;
    font-size: 13px;
    margin: 0;
    padding: 0 8px;
  }
</style>
