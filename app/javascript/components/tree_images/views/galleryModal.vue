<template>
  <div id="image-gallery" v-if='display' @click='closeModal'>
    <div id='image-gallery-internal'>
      <div id='modal-image-container'>
        <img :src='displayedImageDefinition.url' class='modal-image' @click.stop />
      </div>

      <div id='image-gallery-bottom' @click.stop>
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

        <div id='gallery-footer'>
          <b-icon icon='x' id='exit-icon' @click='closeModal'></b-icon>

          <div id='gallery-control-info'>
            <div id='image-counter'>{{ displayedImage + ' / ' + totalImages }}</div>
            <div class='gallery-control' @click='changeDisplayedImage(-1)'>
              <b-icon icon='chevron-left'></b-icon>
            </div>
            <div class='gallery-control' @click='changeDisplayedImage(1)'>
              <b-icon icon='chevron-right'></b-icon>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script>
import EventBus from '@/store/eventBus'

export default {
  props: {
    estimate: {
      required: false
    }
  },
  data() {
    return {
      displayedImage: 1,
      display: false,
      workingEstimate: this.estimate
    }
  },
  computed: {
    imageDefinitions() {
      var allUrls = this.workingEstimate.trees.map((tree, index) => {
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
      this.display = false;
      document.documentElement.style.overflow = 'auto'
    }
  },
  mounted() {
    EventBus.$on('TOGGLE_IMAGE_GALLERY', (payload) => {
      if(payload.estimate != null) {
        this.workingEstimate = payload.estimate;
      }
      var image_id = payload.image_id;
      if(image_id != null) {
        this.displayedImage = (this.imageDefinitions.findIndex(imageDef => imageDef.id === image_id) + 1);
      }
      else {
        this.displayedImage = 1;
      }
      document.documentElement.style.overflow = 'hidden'
      this.display = true;
    });
  }
}
</script>

<style>
  #image-gallery{
    background-color: rgba(0, 0, 0, 0.4);
    position: fixed;
    width: 100%;
    height: 100%;
    left: 0;
    top: 0;

    z-index: 100;
  }

  #image-gallery-internal {
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    width: 100%;
    height: 100%;
  }

  #modal-image-container {
    display: grid;
    height: 100%;
    padding-top: 16px;
    margin-bottom: 16px;
    width: 96%;
    margin-left: auto;
    margin-right: auto;
  }

  .modal-image {
    max-width: 100%;
    height: auto;
  }

  #image-gallery-bottom {
    max-height: 20%;
    background-color: white;
    border-width: 1px 0 0 0;
    border-color: lightgray;
    border-style: solid
  }

  #modal-image-info {
    padding: 4px 8px;
  }

  #gallery-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 4px 8px;

    border-width: 1px 0 0 0;
    border-color: lightgray;
    border-style: solid
  }

  #gallery-control-info {
    display: flex;
    align-items: center;
  }

  .gallery-control {
    font-size: 30px;
    margin-left: 8px;
    cursor: pointer;
  }

  #exit-icon {
    font-size: 30px;
    font-weight: 600;
  }

  @media(min-width: 760px) {
    .modal-image {
      margin: 0 auto;
      height: 100%;
    }

    #image-gallery-bottom {
      width: 50%;
      margin: 0 auto;
    }

      #modal-image-container {
        display: grid;
        height: 80%;
      }

  }

</style>
