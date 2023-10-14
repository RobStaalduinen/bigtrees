<template>
  <div>
    <app-collapsable id='trees-collapse'>
      <template v-slot:title>
        <b>Task Details and Images</b>
      </template>

      <template v-slot:content>
        <div v-for='(tree, index) in estimate.trees' :key='baseKey + " _ " + index' class='tree-section'>
          <div class='tree-header'>
            Task #{{ index + 1 }} {{ tree.formatted_job_type != undefined ? `(${tree.formatted_job_type})` : '' }}
          </div>

          <div v-if='tree.description'>
            <b>Customer Description: </b> {{ tree.description }}
          </div>

          <div class='image-row'>
            <img
              v-for='(image, imageIndex) in tree.tree_images'
              :key='index + "_" + imageIndex'
              :src='image.edited_image_url_sm || image.image_url_sm'
              class='tree-image'
              @click='toggleModal(image.id)'
            />
          </div>
        </div>

        <div class='single-estimate-link-row'>
          <div class='single-estimate-link' v-b-toggle.add-image>
            Add Image
          </div>
        </div>
      </template>
    </app-collapsable>

    <app-image-gallery-modal :estimate='estimate'></app-image-gallery-modal>

    <app-add-image :estimate='estimate' id='add-image'></app-add-image>
  </div>
</template>

<script>
import TreeImageForm from '../../tree_images/actions/addNew';
import ImageGallery from '@/components/tree_images/views/galleryModal';
import EventBus from '@/store/eventBus'

export default {
  components: {
    'app-add-image': TreeImageForm,
    'app-image-gallery-modal': ImageGallery
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
  methods: {
    toggleModal(image_id) {
      EventBus.$emit('TOGGLE_IMAGE_GALLERY', { estimate_id: this.estimate.id, image_id: image_id });
    }
  },
  updated(){
    this.baseKey += 1;
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

  .image-row {
    display: flex;
    width: 100%;
    overflow: scroll;
  }

  .tree-image {
    max-width: 30%;
    margin-right: 8px;
  }
</style>
