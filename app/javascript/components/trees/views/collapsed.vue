<template>
  <div>
    <app-collapsable id='trees-collapse'>
      <template v-slot:title>
        <b>Task Details and Images</b>
      </template>

      <template v-slot:content>
        <div v-for='(tree_id, index) in sortedKeys' :key='baseKey + " _ " + index'>
          <app-single-row
            :index='index'
            :tree='treeForId(tree_id)'
            :is-dragging='isDragging'
            :has-images='sortedImages[tree_id] && sortedImages[tree_id].length > 0'
          >
            <template v-slot:images>
              <draggable
                :list='sortedImages[tree_id]'
                group='tree-images'
                :animation='150'
                :force-fallback='true'
                :delay='200'
                :delay-on-touch-only='false'
                ghost-class='image-ghost'
                chosen-class='image-chosen'
                drag-class='image-drag'
                style='display: flex; flex-wrap: nowrap; min-height: 60px; overflow-x: auto;'
                @start='onDragStart'
                @end='onDragEnd'
@change='onImageMoved($event, tree_id)'
              >
                <app-image-thumb
                  v-for='image in sortedImages[tree_id]'
                  :key='image.id'
                  :image='image'
                  @click='toggleModal(image.id)'
                />
              </draggable>
            </template>
          </app-single-row>
        </div>

        <div class='single-estimate-link-row' v-if="hasPermission('estimates', 'update')">
          <div class='single-estimate-link' v-b-toggle.add-task>
            Add Task
          </div>
          <div class='single-estimate-link' v-b-toggle.add-image>
            Add Image
          </div>
        </div>
      </template>
    </app-collapsable>

    <app-image-gallery-modal :estimate='estimate'></app-image-gallery-modal>

    <app-add-image :estimate='estimate' id='add-image'></app-add-image>
    <app-create-task :estimate='estimate' id='add-task'></app-create-task>
  </div>
</template>

<script>
import Draggable from 'vuedraggable';
import TreeImageForm from '../../tree_images/actions/addNew';
import CreateTask from '@/components/trees/actions/create';
import ImageGallery from '@/components/tree_images/views/galleryModal';
import SingleRow from './singleRow';
import ImageThumb from '@/components/tree_images/forms/imageThumb';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-add-image': TreeImageForm,
    'app-image-gallery-modal': ImageGallery,
    'app-single-row': SingleRow,
    'app-create-task': CreateTask,
    'app-image-thumb': ImageThumb,
    'draggable': Draggable
  },
  props: {
    estimate: {
      required: true
    }
  },
  data() {
    return {
      displayedImage: null,
      baseKey: 1000,
      isDragging: false
    }
  },
  computed: {
    sortedImages() {
      var sortedImages = this.estimate.trees.reduce((acc, tree) => {
        acc[tree.id] = [];
        return acc;
      }, {});

      sortedImages['null'] = [];

       this.estimate.tree_images.map((image) => {
        sortedImages[image.tree_id].push(image);
      },);

      return sortedImages;
    },
    sortedKeys() {
      let initialKeys = Object.keys(this.sortedImages).filter(x => x != 'null');
      initialKeys = initialKeys.sort()
      initialKeys.unshift(null);
      return initialKeys;
    }
  },
  methods: {
    toggleModal(image_id) {
      EventBus.$emit('TOGGLE_IMAGE_GALLERY', { estimate_id: this.estimate.id, image_id: image_id });
    },
    treeForId(treeId) {
      return this.estimate.trees.find(tree => tree.id == treeId);
    },
    onDragStart() {
      this.isDragging = true;
    },
    onDragEnd() {
      this.isDragging = false;
      this.hoveringTreeId = null;
    },
    onImageMoved(event, newTreeId) {
      if (!event.added) return;
      const image = event.added.element;
      const treeId = newTreeId == null || newTreeId === 'null' ? null : newTreeId;
      this.axiosPut(`/tree_images/${image.id}`, {
        tree_id: treeId,
        estimate_id: this.estimate.id
      });
    }
  },
  updated(){
    if (!this.isDragging) {
      this.baseKey += 1;
    }
  }
}
</script>

<style>
  .image-ghost {
    opacity: 0.4;
  }

  .image-chosen {
    box-shadow: 0 0 0 2px #4a90d9;
  }
</style>
