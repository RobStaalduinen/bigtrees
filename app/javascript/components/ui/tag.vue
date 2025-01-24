<template>
  <div class='tag' :style="{ backgroundColor: tag.colour }" @click="$emit('click')">
    <div>{{ tag.label }}</div>

    <div v-if="action === 'delete'" class="tag-icon">
      <b-icon
        icon="x-circle"
      />
    </div>
    <div v-if="action === 'add'" class="tag-icon">
      <b-icon
        icon="plus-circle"
      />
    </div>
  </div>
</template>

<script>

export default {
  props: {
    tag: {
      type: Object,
      required: true
    },
    action: {
      type: String,
      default: null,

    }
  },
}
</script>

<style scoped>
  .tag {
    color: white;
    padding: 2px 6px;
    border-radius: 8px;
    display: flex;
    align-items: center;

    font-weight: 400;
    line-height: 1.4;
  }

  .tag-icon {
    margin-left: 8px;
    color: white;
    font-size: 1.2em;
  }
</style>
