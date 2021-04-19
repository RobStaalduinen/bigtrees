<template>
  <div id="image-gallery" v-if='display' @click='closeModal'>
    <div id='image-gallery-internal'>
      <div id='modal-image-container'>
        <img :src='displayedUrl' class='modal-image' @click.stop />
      </div>

      <div id='image-gallery-bottom' @click.stop>
        <div id='modal-image-info'>
          <b>{{ displayedImageDefinition.tree.treeName + ', ' + displayedImageDefinition.treeImage.imageName }}</b>
          <div v-if='displayedImageDefinition.tree.workType != "Other"'>
            <b>Work Type: </b>{{ displayedImageDefinition.tree.workType }}
          </div>
          <div v-if='displayedImageDefinition.tree.description'>
            <b>Customer Description: </b> {{ displayedImageDefinition.tree.description }}
          </div>
          <div v-if='displayedImageDefinition.tree.workType == "Removal"'>
            <b>Stump Removal: </b> {{ displayedImageDefinition.tree.stumpRemoval }}
          </div>
        </div>

        <div id='modal-edits'>
          <div class='modal-edits-left'>
            <div
              class='modal-edits-link'
              v-bind:class="{ 'modal-edits-link-active': imageVersion == 'original' }"
              @click='changeImageVersion("original")'
            >
              Original
            </div>

            <div
              class='modal-edits-link'
              v-if='hasEdit'
              v-bind:class="{ 'modal-edits-link-active': imageVersion == 'edited' }"
              @click='changeImageVersion("edited")'
            >
              Edited
            </div>

            <div
              v-else
              class='modal-edits-link'
            >
              No Edited version
            </div>
          </div>
          <div class='modal-edits-icon'>
            <b-icon icon='pencil-square' @click='toggleEdit(displayedImageDefinition.treeImage.id)'></b-icon>
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

    <app-image-markup
      v-if='editedId != null'
      :imageUrl='displayedUrl'
      @cancel='editedId = null'
      :onSave='onEditSave'
    ></app-image-markup>
  </div>
</template>

<script>
import EventBus from '@/store/eventBus'
import Markup from './markup';
import { base64ToBlob } from '@/utils/fileUtils';
import { signedUrlFormData, parseImageUploadResponse } from '@/utils/awsS3Utils';
import { Tree, TreeImage } from '@/models';

export default {
  components: {
    'app-image-markup': Markup
  },
  props: {
    estimate: {
      required: false
    }
  },
  data() {
    return {
      displayedImage: 1,
      display: false,
      imageVersion: null,
      editedId: null
    }
  },
  computed: {
    imageDefinitions() {
      var allUrls = this.estimate.trees.map((tree, index) => {
        return tree.tree_images.map((image, imageIndex) => {
          return {
            tree: new Tree(tree).galleryDisplay(index),
            treeImage: new TreeImage(image).galleryDisplay(imageIndex)
          }
        })
      })

      return [].concat.apply([], allUrls);
    },
    displayedImageDefinition() {
      var image = this.imageDefinitions[this.displayedImage - 1];
      return image ? image : { treeImage: { url: null, imageName: null }, tree: { workType: 'other' }}
    },
    totalImages() {
      return this.imageDefinitions.length;
    },
    hasEdit() {
      return this.displayedImageDefinition.treeImage.edited_url != null
    },
    displayedUrl(){
      return this.imageVersion == 'edited' ? this.displayedImageDefinition.treeImage.edited_url : this.displayedImageDefinition.treeImage.url
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

      this.setInitialImageVersion();
    },
    closeModal() {
      this.display = false;
      document.documentElement.style.overflow = 'auto'
    },
    setInitialImageVersion(){
      this.imageVersion = this.hasEdit ? 'edited' : 'original'
    },
    changeImageVersion(imageType) {
      this.imageVersion = imageType;
    },
    toggleEdit(imageId) {
      this.editedId = imageId;
    },
    onEditSave(image_base64) {
      this.axiosGet('/tree_images/new', { filename: 'edited' }).then(response => {
        const formData = signedUrlFormData(response.data.fields, base64ToBlob(image_base64));

        this.axiosImagePost(response.data.url, formData).then(imgResponse => {
          var params = { edited_image_url: parseImageUploadResponse(imgResponse) };

          this.axiosPut(`/tree_images/${this.editedId}?estimate_id=${this.estimate.id}`, params).then(response => {
            this.changeImageVersion('edited');
            EventBus.$emit('ESTIMATE_UPDATED', response.data);
            this.toggleEdit(null, null);
          })
        })
      })
    },
    setImageById(imageId) {
      this.displayedImage = imageId != null ? this.findImageById(imageId) : 1;
    },
    findImageById(imageId) {
      return this.imageDefinitions.findIndex(imageDef => imageDef.treeImage.id === imageId) + 1;
    }
  },
  mounted() {
    EventBus.$on('TOGGLE_IMAGE_GALLERY', (payload) => {
      if(payload.estimate_id != null && payload.estimate_id != this.estimate.id) {
        return;
      }
      this.setImageById(payload.image_id);
      this.setInitialImageVersion();
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
    display: flex;
    justify-content: center;
    height: 100%;
    padding-top: 16px;
    margin-bottom: 16px;
    width: 96%;
    margin-left: auto;
    margin-right: auto;
  }

  .modal-image {
    width: 100%;
    height: 100%;
    object-fit: contain;
  }

  #modal-edits {
    display: flex;
    justify-content: space-between;

    border-style: solid;
    border-color: lightgray;
    border-width: 1px 0 0 0;
  }

  .modal-edits-left {
    display: flex;
  }

  .modal-edits-link {
    display: flex;
    justify-content: center;
    padding: 8px 16px;
    margin-right: 16px;
    cursor: pointer;
  }

  .modal-edits-link-active {
    background-color: var(--main-color);
    color: white;
  }

  .modal-edits-icon {
    display: flex;
    justify-content: center;
    align-items: center;
    color: var(--main-color);
    font-size: 22px;
    padding: 8px;

    border-style: solid;
    border-color: lightgray;
    border-width: 0 0 0 1px;

    cursor: pointer;
  }

  #image-gallery-bottom {
    background-color: white;
    border-width: 1px 0 0 0;
    border-color: lightgray;
    border-style: solid;
    padding-bottom: 16px;
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
    border-style: solid;
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
    #image-gallery-bottom {
      width: 50%;
      margin: 0 auto;
    }

      #modal-image-container {
        /* display: grid; */
        height: 80%;
      }

  }

</style>
