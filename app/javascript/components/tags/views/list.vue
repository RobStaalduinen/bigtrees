<template>
  <div id="tag-list">
    <div class="tag-container" v-for="(tag, index) in tags" :key="tag.id" v-if="!shouldCollapse()">
      <app-tag :tag="tag" :index="index" />
    </div>

    <template v-if="shouldCollapse() && tags.length > 0">
      <div class="tag-container"><app-tag :tag="tags[0]" :index="index" /></div>
      <div class="tag-container"><app-tag :tag="{ label: `+ ${tags.length - 1}`, colour: 'grey' }" /></div>
    </template>
  </div>
</template>

<script>

export default {
  props: {
    tags: {
      type: Array,
      required: true
    },
    collapsed: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    shouldCollapse() {
      return this.collapsed && this.tags.length > 1
    }
  }
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
