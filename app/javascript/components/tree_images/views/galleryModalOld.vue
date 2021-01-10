<template>
  <b-modal id="image-modal" modal-class="bottom-modal" centered>
    <template v-slot:modal-header><span></span></template>

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
        <div v-if='displayedImageDefinition.workType == "Removal"'>
          <b>Stump Removal: </b> {{ displayedImageDefinition.stumpRemoval }}
        </div>
      </div>
    </div>

    <template v-slot:modal-footer>
      <div id='modal-footer'>
        <b-icon icon='x' id='exit-icon' @click='closeModal'></b-icon>

        <div id='modal-info'>
          <div id='image-counter'>{{ displayedImage + ' / ' + totalImages }}</div>
          <div class='modal-control' @click='changeDisplayedImage(-1)'>
            <b-icon icon='chevron-left'></b-icon>
          </div>
          <div class='modal-control' @click='changeDisplayedImage(1)'>
            <b-icon icon='chevron-right'></b-icon>
          </div>
        </div>
      </div>
    </template>
  </b-modal>
</template>

<script>
import EventBus from '@/store/eventBus'

export default {
  props: {
    estimate: {
      required: true
    }
  },
  data() {
    return {
      displayedImage: 1,
    }
  },
  computed: {
    imageDefinitions() {
      var allUrls = this.estimate.trees.map((tree, index) => {
        return tree.tree_images.map((image, imageIndex) => {
          return {
            id: image.id,
            url: image.url,
            imageName: `Task #${index+1}, Image #${imageIndex+1}`,
            workType: tree.work_name,
            description: tree.description,
            stumpRemoval: tree.stumpRemoval ? 'Yes' : 'No'
          }
        })
      })

      return [].concat.apply([], allUrls);
    },
    displayedImageDefinition() {
      var image = this.imageDefinitions[this.displayedImage - 1];
      return image ? image : { url: null, imageName: null, workType: 'other'}
    },
    totalImages() {
      return this.imageDefinitions.length;
    }
  },
  methods: {
    changeDisplayedImage(step) {
      this.displayedImage += step;
      if(this.displayedImage == 0) {
        this.displayedImage = this.totalImages
      }
      if(this.displayedImage > this.totalImages) {
        this.displayedImage = 1;
      }
    },
    closeModal() {
      this.$bvModal.hide('image-modal');
    }
  },
  mounted() {
    EventBus.$on('TOGGLE_IMAGE_GALLERY', (image_id) => {
      if(image_id != null) {
        this.displayedImage = (this.imageDefinitions.findIndex(imageDef => imageDef.id === image_id) + 1);
      }
      else {
        this.displayedImage = 1;
      }

      this.$bvModal.show('image-modal');
    });
  }
}
</script>

<style>
  #image-modal > .modal-dialog > .modal-content > .modal-header {
    padding: 0;
  }

 #modal-image-info{
    display: flex;
    flex-direction: column;
    margin-top: 8px;
    padding: 8px;

    font-size: 14px;

    background-color: #f5f5f5;

  }

  #modal-info {
    display: flex;
    align-items: center
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
    justify-content: space-between;
    width: 100%;
  }

  #exit-icon {
    font-size: 22px;
    font-weight: 600;
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
