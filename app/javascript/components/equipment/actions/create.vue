<template>
    <app-right-sidebar :id='id' title='Create Equipment Request' submitText='Submit' :onSubmit='createEquipmentRequest' @cancelled='reset'>
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
            <label class='d-block'>Image</label>
            <app-file-upload
              v-model='image_url'
              accept=".jpg, .jpeg, .png"
              bucketName='equipment-requests'
              @upload-status-changed='handleUploadStatus'
            ></app-file-upload>
          </div>

          <div class='error-box' v-if='errorMessage'>
            {{ errorMessage }}
          </div>
        </validation-observer>
      </template>
  </app-right-sidebar>
</template>

<script>
import FileUpload from '@/components/file/actions/upload';
import EventBus from '@/store/eventBus';
import moment from 'moment';

export default {
  props: ['id'],
  components: {
    'app-file-upload': FileUpload
  },
  data() {
    return {
      description: null,
      vehicle_id: null,
      category: 'other',
      image_url: null,
      errorMessage: null,
      vehicles: [],
      uploading: false
    }
  },
  computed: {
    vehicleOptions() {
      let vehicleList = this.vehicles.map(vehicle => {
        return { value: vehicle.id, text: vehicle.name }
      })

      vehicleList.push({value: null, text: 'None'})

      return vehicleList;
    },
    categoryOptions() {
      return ['other', 'mechanical', 'equipment', 'supplies', 'paperwork'].map(category => {
        return {
          value: category,
          text: category.charAt(0).toUpperCase() + category.slice(1)
        }
      })
    }
  },
  methods: {
    createEquipmentRequest() {
      this.errorMessage = null;
      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }

        if(this.uploading && !this.image_url) {
          this.errorMessage = 'Please wait for upload to finish before submitting';
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return
        }

        let params = { equipment_request: {
          description: this.description,
          category: this.category,
          vehicle_id: this.vehicle_id,
          image_url: this.image_url
        }}

        this.axiosPost('/equipment_requests', params).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('EQUIPMENT_REQUEST_UPDATED');
          setTimeout(() => {
            this.reset();
          }, 500);
        })
      })
    },
    populateVehicles() {
      this.axiosGet('/vehicles').then(response => {
        this.vehicles = response.data.vehicles;
      })
    },
    reset() {
      this.description = null;
      this.vehicle_id = null;
      this.category = 'other';
      this.image_url = null;
    },
    handleUploadStatus(uploadStatus) {
      this.uploading = uploadStatus;
    }
  },
  mounted() {
    this.populateVehicles();
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
</style>
