<template>
  <div id="tag-list">
    <div class="tag-container" v-for="(tag, index) in tags" :key="tag.id" v-if="!shouldCollapse()">
      <app-tag :tag="tag" :index="index" />
    </div>

    <template v-if="shouldCollapse()">
      <div class="tag-container"><app-tag :tag="tags[0]" /></div>
      <div class="tag-container"><app-tag :tag="tags[1]" /></div>
      <div class="collapsed-more-container">
        <app-tag
          :tag="{ label: `+ ${tags.length - 2}`, colour: 'grey' }"
          class="more-tag"
          @click="togglePopover"
        />
        <div v-if="showPopover" class="tag-popover" @click="showPopover = false">
          <div class="tag-container" v-for="tag in tags.slice(2)" :key="tag.id">
            <app-tag :tag="tag" />
          </div>
        </div>
      </div>
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
  data() {
    return {
      showPopover: false
    }
  },
  methods: {
    shouldCollapse() {
      return this.collapsed && this.tags.length > 2
    },
    togglePopover() {
      this.showPopover = !this.showPopover
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

  .collapsed-more-container {
    position: relative;
  }

  .more-tag {
    cursor: pointer;
  }

  .tag-popover {
    position: absolute;
    bottom: calc(100% + 4px);
    left: 0;
    background: white;
    border: 1px solid lightgray;
    border-radius: 6px;
    padding: 6px;
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
    z-index: 100;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    min-width: 120px;
    cursor: pointer;
  }
</style>
