<template>
  <div class='task-card' :class="{ 'task-card--uncategorized': !tree }">
    <div class='task-card__header'>
      <h4 class='task-card__title'>{{ title }}</h4>

      <div v-if='tree' class='task-card__actions'>
        <app-pill
          v-if='tree.stump_removal'
          text='Stump'
          tone='warning'
          filled
          icon='tree'
        />
        <app-pill
          v-if='tree.in_backyard'
          text='Backyard'
          tone='success'
          filled
          icon='house-door'
        />
        <b-icon
          v-if='hasPermission("estimates", "update")'
          icon='pencil-square'
          class='app-icon edit-icon'
          title='Edit task'
          @click='$emit("edit", tree)'
        ></b-icon>
      </div>
    </div>

    <p
      v-if='tree'
      class='task-card__description'
      :class="{ 'is-empty': !tree.description }"
    >
      {{ tree.description || 'No description' }}
    </p>

    <div class='task-card__images image-row' :class="{ 'drop-zone--active': isDragging }">
      <slot name='images' />

      <div v-if='hasPermission("estimates", "update")' class='task-card__add-images-row'>
        <span
          class='task-card__add-images'
          title='Add images to this section'
          @click='$emit("add-images", tree)'
        >
          <b-icon icon='image'></b-icon> Add Images
        </span>
      </div>
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
  computed: {
    title() {
      return this.tree ? `${this.index}. ${this.tree.work_type_name}` : 'Uncategorized';
    }
  }
}
</script>

<style scoped>
  .task-card {
    background: var(--surface-sunken);
    border: 1px solid var(--border);
    padding: var(--space-3) var(--space-4);
    margin-bottom: var(--space-4);
    box-shadow: var(--shadow-sm);
    overflow: hidden;
  }

  /* The catch-all bucket reads as a holding area, not a real task. */
  .task-card--uncategorized {
    background: var(--surface-alt);
    border-style: dashed;
    box-shadow: none;
  }

  .task-card__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--space-2);
    flex-wrap: wrap;
  }

  /* Compact title — matches the description's size/font so it stays inline
     with the attribute pills, in the subtler muted grey of the old eyebrow. */
  .task-card__title {
    margin: 0;
    font-size: var(--text-sm);
    font-weight: 600;
    color: var(--text-muted);
  }

  .task-card__actions {
    display: flex;
    flex-wrap: wrap;
    gap: var(--space-1);
    align-items: center;
  }

  /* Tighten the pills' own padding so the title + both pills + edit icon are
     more likely to stay on one line on narrow screens. */
  .task-card__actions ::v-deep .pill {
    padding: 2px var(--space-1);
  }

  /* Compact inline description — sits tight under the title. */
  .task-card__description {
    margin: 2px 0 0;
    font-size: var(--text-sm);
    color: var(--text);
    white-space: pre-line;
  }

  .task-card__description.is-empty {
    color: var(--text-muted);
    font-style: italic;
  }

  /* White image strip at the bottom of the card, against the grey header area.
     The negative margins cancel the card's padding so the white reaches the
     card's side and bottom edges, while its own small padding keeps the images
     off those edges. */
  .image-row {
    margin: var(--space-3) calc(-1 * var(--space-4)) calc(-1 * var(--space-3));
    padding: var(--space-2);
    min-height: 60px;
    background: var(--surface);
    transition: background var(--transition-fast);
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
  }

  .drop-zone--active {
    background: var(--color-brand-wash);
  }

  /* Add Images sits at the bottom-right of the image box, below the thumbnails
     and outside their horizontal scroll area so it always stays in view. */
  .task-card__add-images-row {
    display: flex;
    justify-content: flex-end;
  }

  .task-card__add-images {
    display: inline-flex;
    align-items: center;
    gap: var(--space-1);
    font-size: var(--text-sm);
    font-weight: 600;
    color: var(--main-color);
    cursor: pointer;
    white-space: nowrap;
  }
</style>
