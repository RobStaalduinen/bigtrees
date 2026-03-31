# Implementation Plan: Drag and Drop Task Images

**Spec:** ENG-1
**Date:** 2026-03-29

---

## Overview

The goal is to allow arborists to drag images between tasks (and to/from the uncategorized pool) on the estimate detail page. The drag-and-drop interaction must work on both desktop and mobile. No backend data model changes are required — the existing `PUT /tree_images/:id` endpoint already accepts a `tree_id` parameter.

---

## Library Choice: `vuedraggable`

Add the [`vuedraggable`](https://github.com/SortableJS/Vue.Draggable) package (v2.x, compatible with Vue 2). It wraps SortableJS, which has built-in touch support — covering the mobile requirement without custom touch event handling.

```bash
yarn add vuedraggable
```

---

## What Changes

### No backend changes
The `PUT /tree_images/:id` endpoint in `TreeImagesController` already accepts `tree_id` and updates the association. No new routes, models, or serializers are needed.

### Frontend: 3 files modified, 0 new files

---

## File-by-File Plan

### 1. `app/javascript/components/trees/views/collapsed.vue`

This is the main container that renders all tasks and their images. It owns the `sortedImages` computed property (a map of `tree_id → [TreeImage, ...]`) and passes data down to `singleRow`.

**Changes:**

- Import `vuedraggable` locally (not globally needed).
- Add a `isDragging` data property (boolean), set to `true` on `dragstart`, `false` on `dragend`. This drives visual cues across all rows.
- Replace the static image list rendered inside `singleRow` with a `<draggable>` group. Since `singleRow` currently handles its own image rendering, the cleanest approach is to lift the image list up into `collapsed.vue` and pass it down, so that all task image-lists share the same draggable `group` name (enabling cross-list drag).

**New structure (sketch):**

```vue
<div
  v-for="treeId in sortedKeys"
  :key="treeId"
>
  <single-row
    :tree="treeForId(treeId)"
    :is-dragging="isDragging"
    @start-drag="isDragging = true"
    @end-drag="isDragging = false"
  >
    <!-- Images slot passed as draggable list -->
    <draggable
      :list="sortedImages[treeId]"
      group="tree-images"
      :animation="150"
      ghost-class="image-ghost"
      chosen-class="image-chosen"
      drag-class="image-drag"
      @start="isDragging = true"
      @end="isDragging = false"
      @change="onImageMoved($event, treeId)"
    >
      <image-thumb
        v-for="image in sortedImages[treeId]"
        :key="image.id"
        :image="image"
      />
    </draggable>
  </single-row>
</div>
```

**`onImageMoved(event, newTreeId)` handler:**

SortableJS fires a `change` event with an `added` property when an item is dropped into a new list. Use this to call the API:

```javascript
onImageMoved(event, newTreeId) {
  if (!event.added) return; // only act on drops, not removals from old list
  const image = event.added.element;
  const treeId = newTreeId === 'uncategorized' ? null : newTreeId;
  this.axiosPut(`/tree_images/${image.id}`, { tree_id: treeId })
    .then(() => this.$eventBus.$emit('ESTIMATE_UPDATED'));
}
```

The `sortedImages` map is already reactive (computed from the estimate), so the UI updates immediately via SortableJS's DOM manipulation, and the event bus refresh keeps the Vuex store consistent.

---

### 2. `app/javascript/components/trees/views/singleRow.vue`

Currently renders the task header and its image thumbnails directly. With the change above, the image list is owned by the parent and passed in via a slot.

**Changes:**

- Accept an `isDragging` prop (Boolean).
- Render a named slot for the image list (instead of iterating images internally).
- When `isDragging` is true, apply a visual class to the drop zone area (e.g., a highlighted border around the image row) so the user knows where they can drop.

```vue
<div
  class="image-row"
  :class="{ 'drop-zone--active': isDragging }"
>
  <slot name="images" />
  <p v-if="isDragging && !hasImages" class="drop-hint">Drop here</p>
</div>
```

CSS (scoped):
```scss
.drop-zone--active {
  border: 2px dashed #4a90d9;
  border-radius: 4px;
  min-height: 80px;
}
.image-ghost {
  opacity: 0.4;
}
.image-chosen {
  box-shadow: 0 0 0 2px #4a90d9;
}
```

A "Drop here" hint is shown when a task has no images and the user is dragging — this makes empty task drop zones discoverable.

---

### 3. `app/javascript/components/tree_images/forms/imageThumb.vue` *(new small component, extracted from singleRow)*

Currently `singleRow.vue` renders image thumbnails inline. To make them individually draggable with proper drag handles and visual feedback, extract a small `imageThumb.vue` component.

**Responsibilities:**
- Render the thumbnail `<img>` tag.
- Add a `draggable="true"` attribute (SortableJS handles the actual drag event, this just enables the cursor to change on hover).
- Show a small drag handle icon (e.g., `⠿`) on hover so users on desktop know the image is draggable.
- Emit `click` to open the gallery (preserving existing behavior).

```vue
<template>
  <div class="image-thumb" @click="$emit('click', image.id)">
    <span class="drag-handle">⠿</span>
    <img :src="image.image_small_url || image.image_url" :alt="image.id" />
  </div>
</template>
```

---

## Interaction Flow

### Desktop
1. User hovers over an image — drag handle icon appears.
2. User presses and drags — SortableJS creates a ghost clone of the image.
3. All task rows show a dashed drop zone border.
4. User drags over a task row — it highlights.
5. User releases — image snaps into the new row instantly (optimistic DOM update by SortableJS).
6. `onImageMoved` fires → `PUT /tree_images/:id` → `ESTIMATE_UPDATED`.

### Mobile
SortableJS handles `touchstart`/`touchmove`/`touchend` automatically. No additional code needed. The behavior is identical — the image follows the user's finger.

---

## Error Handling

If the API call fails:
- Emit `ESTIMATE_UPDATED` anyway to force a re-fetch from the server, which will snap the UI back to the correct state.
- Optionally show a toast notification using the existing pattern in the codebase.

---

## Testing

No existing specs cover the Vue components (RSpec only). Manual test matrix:

| Scenario | Expected |
|---|---|
| Drag uncategorized image to a task | Image appears in task row; `tree_id` updated in DB |
| Drag task image to uncategorized | Image appears in uncategorized; `tree_id` set to null |
| Drag image to a different task | Image moves; old task loses it |
| Drag on mobile (iOS/Android) | Same behavior via touch |
| Drop into empty task row | "Drop here" hint visible; image lands correctly |
| API failure on drop | Re-fetch restores correct state |

---

## Summary of Changes

| File | Change |
|---|---|
| `package.json` | Add `vuedraggable` |
| `collapsed.vue` | Own image lists; wrap each in `<draggable>`; add `onImageMoved` handler |
| `singleRow.vue` | Accept `isDragging` prop; use slot for images; show drop zone styles |
| `imageThumb.vue` | New small component extracted from `singleRow`; adds drag handle |
