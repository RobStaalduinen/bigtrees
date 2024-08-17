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
            :images='sortedImages[tree_id]'
            @edit='(image_id) => toggleModal(image_id)'
          ></app-single-row>

        </div>

        <div class='single-estimate-link-row'>
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
import TreeImageForm from '../../tree_images/actions/addNew';
import CreateTask from '@/components/trees/actions/create';
import ImageGallery from '@/components/tree_images/views/galleryModal';
import EventBus from '@/store/eventBus'
import SingleRow from './singleRow';

export default {
  components: {
    'app-add-image': TreeImageForm,
    'app-image-gallery-modal': ImageGallery,
    'app-single-row': SingleRow,
    'app-create-task': CreateTask
  },
  props: {
    estimate: {
      required: true
    }
  },
  data() {
    return {
      displayedImage: null,
      baseKey: 1000
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
      console.log(initialKeys);
      initialKeys.unshift(null);
      return initialKeys;
    }
  },
  methods: {
    toggleModal(image_id) {
      EventBus.$emit('TOGGLE_IMAGE_GALLERY', { estimate_id: this.estimate.id, image_id: image_id });
    },
    treeForId(treeId) {
      console.log(this.estimate.trees);
      console.log(treeId);
      return this.estimate.trees.find(tree => tree.id == treeId);
    }
  },
  updated(){
    this.baseKey += 1;
  }
}
</script>

<style scoped>

</style>
