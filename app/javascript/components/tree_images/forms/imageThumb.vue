<template>
  <div class="image-thumb" @click="$emit('click', image.id)">
    <span class="drag-handle">⠿</span>
    <img :src="image.edited_image_url || image.image_url" :alt="image.id" class="thumb-img" />
  </div>
</template>

<script>
export default {
  props: {
    image: {
      required: true,
      type: Object
    }
  }
}
</script>

<style scoped>
.image-thumb {
  position: relative;
  max-width: 30%;
  flex-shrink: 0;
  margin-right: 8px;
  cursor: grab;
}

.image-thumb:active {
  cursor: grabbing;
}

.drag-handle {
  position: absolute;
  top: 2px;
  left: 2px;
  color: white;
  background: rgba(0, 0, 0, 0.4);
  border-radius: 2px;
  padding: 0 3px;
  font-size: 12px;
  opacity: 0;
  transition: opacity 0.15s;
  pointer-events: none;
}

.image-thumb:hover .drag-handle {
  opacity: 1;
}

.thumb-img {
  max-width: 100%;
  display: block;
}
</style>
