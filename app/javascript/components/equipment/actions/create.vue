<template>
    <app-right-sidebar-form
      :id='id'
      title='Create Equipment Request'
      submitText='Submit'
      :onSubmit='createEquipmentRequest'
      @cancelled='reset'
      :submitting='submitting'
    >
      <template v-slot:content>
        <validation-observer ref="observer">
          <app-select-field
            label='Category'
            v-model='category'
            name='category'
            :options="categoryOptions"
            validationRules='required'
          />

          <app-select-field
            label='Vehicle'
            v-model='vehicle_id'
            name='vehicle'
            :options="vehicleOptions"
          />

          <app-input-field
            v-model='description'
            name="description"
            label='Description'
            validationRules='required'
          ></app-input-field>

          <div>
            <label class='d-block'>Images</label>

            <!-- Already-saved images (edit mode). New picks go through app-uploader below. -->
            <div v-if='existingImageUrls.length' class='existing-images'>
              <div v-for='url in existingImageUrls' :key='url' class='existing-image'>
                <img :src='url' class='existing-image__thumb' />
                <b-icon
                  icon='x-circle-fill'
                  class='existing-image__remove'
                  title='Remove'
                  @click='removeExistingImage(url)'
                ></b-icon>
              </div>
            </div>

            <app-uploader
              :key='uploaderKey'
              :value='uploads'
              :multiple='true'
              :target='null'
              accept=".jpg, .jpeg, .png"
              bucketName='equipment-requests'
              presignPath='/files/new'
              @input='uploads = $event'
            ></app-uploader>
          </div>

          <div class='error-box' v-if='errorMessage'>
            {{ errorMessage }}
          </div>
        </validation-observer>
      </template>
  </app-right-sidebar-form>
</template>

<script>
// app-uploader is registered globally (packs/admin.js).
import EventBus from '@/store/eventBus';
import moment from 'moment';

export default {
  props: {
    id: {
      required: true
    },
    equipmentRequest: {
      required: false,
      type: Object
    }
  },
  data() {
    return {
      description: null,
      vehicle_id: null,
      category: 'other',
      // URLs of images already saved on the request being edited.
      existingImageUrls: [],
      // app-uploader's emitted job list: [{ id, clientUploadId, status, url }]
      uploads: [],
      // Bumped on reset so app-uploader remounts with an empty job list.
      uploaderKey: 0,
      errorMessage: null,
      vehicles: [],
      submitting: false
    }
  },
  computed: {
    vehicleOptions() {
      let vehicleList = this.vehicles.map(vehicle => {
        return { value: vehicle.id, text: vehicle.name }
      })

      // Vehicle is optional, so 'None' leads as the default selection.
      vehicleList.unshift({value: null, text: 'None'})

      return vehicleList;
    },
    categoryOptions() {
      return ['other', 'mechanical', 'equipment', 'supplies', 'paperwork'].map(category => {
        return {
          value: category,
          text: category.charAt(0).toUpperCase() + category.slice(1)
        }
      })
    },
    // Uploads still transferring to S3 ('success' is done, 'fatalError' is
    // shown as failed in the uploader and simply skipped on submit).
    pendingUploads() {
      return this.uploads.filter(upload => upload.status !== 'success' && upload.status !== 'fatalError');
    },
    imageUrls() {
      const uploadedUrls = this.uploads
        .filter(upload => upload.status === 'success' && upload.url)
        .map(upload => upload.url);

      return this.existingImageUrls.concat(uploadedUrls);
    }
  },
  methods: {
    createEquipmentRequest() {
      this.errorMessage = null;
      this.submitting = true;
      this.$refs.observer.validate().then(success => {
        if (!success) {
          this.submitting = false;
          return;
        }

        if(this.pendingUploads.length) {
          this.errorMessage = 'Please wait for uploads to finish before submitting';
          this.submitting = false;
          return
        }

        let params = { equipment_request: {
          description: this.description,
          category: this.category,
          vehicle_id: this.vehicle_id,
          image_urls: this.imageUrls
        }}

        let promise = null;
        if(this.equipmentRequest) {
          promise = this.axiosPut(`/equipment_requests/${this.equipmentRequest.id}`, params)
        }
        else {
          promise = this.axiosPost('/equipment_requests', params)
        }

        promise.then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('EQUIPMENT_REQUEST_UPDATED');
          setTimeout(() => {
            this.reset();
          }, 500);
        }).finally(() => {
          this.submitting = false;
        })
      })
    },
    populateVehicles() {
      this.axiosGet('/vehicles').then(response => {
        this.vehicles = response.data.vehicles;
      })
    },
    setInitialData() {
      this.reset();

      if(!this.equipmentRequest) {
        return
      }

      this.description = this.equipmentRequest.description;
      this.existingImageUrls = [...(this.equipmentRequest.image_urls || [])];
      this.category = this.equipmentRequest.category;

      if(this.equipmentRequest.vehicle){
        this.vehicle_id = this.equipmentRequest.vehicle.id;
      }
    },
    reset() {
      this.description = null;
      this.vehicle_id = null;
      this.category = 'other';
      this.existingImageUrls = [];
      this.uploads = [];
      this.uploaderKey += 1;
      this.errorMessage = null;
    },
    removeExistingImage(url) {
      this.existingImageUrls = this.existingImageUrls.filter(existingUrl => existingUrl !== url);
    }
  },
  mounted() {
    this.populateVehicles();
    this.setInitialData();
  },
  watch: {
    equipmentRequest() {
      this.setInitialData();
    }
  }
}
</script>

<style scoped>
  #form-container {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 100%;
  }

  #delete-button {
    margin-top: 64px;
    padding: 2px;
  }

  /* Mirrors app-uploader's thumbnail grid so saved and new images line up. */
  .existing-images {
    display: flex;
    flex-wrap: wrap;
    gap: var(--space-2);
    margin-bottom: var(--space-2);
  }

  .existing-image {
    position: relative;
    width: 88px;
    height: 88px;
    border-radius: var(--radius-sm);
    overflow: hidden;
    border: 1px solid var(--neutral);
  }

  .existing-image__thumb {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }

  .existing-image__remove {
    position: absolute;
    top: var(--space-1);
    right: var(--space-1);
    color: #fff;
    font-size: var(--text-lg);
    cursor: pointer;
    filter: drop-shadow(0 1px 1px rgba(0, 0, 0, 0.6));
  }
</style>
