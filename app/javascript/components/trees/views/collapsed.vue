<template>
  <div>
    <app-collapsable id='trees-collapse'>
      <template v-slot:title>
        <b>Task Details and Images</b>
      </template>

      <template v-slot:content>
        <div v-for='(tree, index) in estimate.trees' :key='baseKey + " _ " + index' class='tree-section'>
          <div class='tree-header'>
            Task #{{ index + 1 }} {{ tree.work_name != "Other" ? `(${tree.work_name})` : '' }}
          </div>

          <div v-if='tree.description'>
            <b>Customer Description: </b> {{ tree.description }}
          </div>

          <div class='image-row'>
            <img
              v-for='(image, imageIndex) in tree.tree_images'
              :key='index + "_" + imageIndex'
              :src='image.url'
              class='tree-image'
              @click='toggleModal(index, imageIndex)'
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

    <b-modal id="image-modal" modal-class="bottom-modal" centered>
      <div id='modal-body'>
        <div id='modal-image-container'>
          <img :src='displayedImageDefinition.url' class='modal-image'/>
        </div>

        <div id='modal-image-info'>
          <b>{{ displayedImageDefinition.imageName }}</b>
          <div v-if='displayedImageDefinition.workType != "Other"'>
            <b>Work Type: </b>{{ displayedImageDefinition.workType }}
          </div>
          <div v-if='displayedImageDefinition.description'>
            <b>Customer Description: </b> {{ displayedImageDefinition.description }}
          </div>
        </div>
      </div>

      <template v-slot:modal-footer>
        <div id='modal-footer'>
          <div id='image-counter'>{{ displayedImage + ' / ' + totalImages }}</div>
          <div class='modal-control' @click='changeDisplayedImage(-1)'>
            <b-icon icon='chevron-left'></b-icon>
          </div>
          <div class='modal-control' @click='changeDisplayedImage(1)'>
            <b-icon icon='chevron-right'></b-icon>
          </div>
        </div>
      </template>
    </b-modal>

    <app-add-image :estimate='estimate' id='add-image' @changed="(payload) => $emit('changed', payload)"></app-add-image>
  </div>
</template>

<script>
import TreeImageForm from '../../tree_images/actions/addNew';

export default {
  components: {
    'app-add-image': TreeImageForm
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
    imageUrls() {
      var allUrls = this.estimate.trees.map((tree, index) => {
        return tree.tree_images.map((image, imageIndex) => {
          return {
            url: image.url,
            imageName: `Task #${index+1}, Image #${imageIndex+1}`,
            workType: tree.work_name,
            description: tree.description
          }
        })
      })

      return [].concat.apply([], allUrls);
    },
    displayedImageDefinition() {
      var image = this.imageUrls[this.displayedImage - 1];
      return image ? image : { url: null, imageName: null, workType: 'other'}
    },
    totalImages() {
      return this.imageUrls.length;
    }
  },
  methods: {
    toggleModal(treeIndex, imageIndex) {
      this.displayedImage = (treeIndex + 1) * (imageIndex + 1);
      this.$bvModal.show('image-modal');
    },
    changeDisplayedImage(step) {
      this.displayedImage += step;
      if(this.displayedImage == 0) {
        this.displayedImage = this.totalImages
      }
      if(this.displayedImage > this.totalImages) {
        this.displayedImage = 1;
      }
    }
  },
  updated(){
    console.log('UPDATED');
    console.log(this.estimate);
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
    display: flex
  }

  .tree-image {
    max-width: 30%;
    margin-right: 8px;
  }

  #modal-image-info{
    display: flex;
    flex-direction: column;
    padding-top: 8px;
    margin-top: 8px;

    border-width: 1px 0 0 0;
    border-color: grey;
    border-style: solid;
  }

  #modal-body {
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    min-height: 400px;
  }

  #modal-footer {
    display: flex;
    align-items: center;
  }

  .modal-control {
    padding: 4px 8px;
  }

  #modal-image-container {
    height: 450px;
    display: flex;
    justify-content: center;
  }

  .modal-image {
    max-width:100%;
    max-height:100%;
  }

  #image-counter {
    margin-right: 8px;
  }
</style>
