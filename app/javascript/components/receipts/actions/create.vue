<template>
    <app-right-sidebar :id='id' title='Submit Receipt' submitText='Submit' :onSubmit='createReceipt' @cancelled='reset'>
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
            v-if='organization.id == 1'
            label='Job'
            v-model='job'
            name='job'
            :options="jobOptions"
            validationRules='required'
          />

          <app-select-field
            label='Payment Method'
            v-model='paymentMethod'
            name='payment_method'
            :options="paymentMethodOptions"
            validationRules='required'
          />

          <app-select-field
            label='Vehicle (if applicable)'
            v-model='vehicle_id'
            name='vehicle'
            :options="vehicleOptions"
          />

          <app-input-field
            v-model='cost'
            name='cost'
            label='Cost'
            validationRules='required'
            inputType='number'
          ></app-input-field>

          <app-input-field
            v-model='description'
            name="description"
            label='What did you buy?'
            validationRules='required'
          ></app-input-field>

          <div>
            <label class='d-block'>Receipt Picture</label>
            <app-file-upload
              v-model='image_url'
              accept=".jpg, .jpeg, .png"
              bucketName='receipts'
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

import { stringOptionList, objectOptionList } from '@/utils/formUtils';

export default {
  props: ['id'],
  components: {
    'app-file-upload': FileUpload
  },
  data() {
    return {
      description: null,
      vehicle_id: null,
      category: 'fuel',
      job: 'Big Trees',
      paymentMethod: 'Corporate Card',
      cost: null,
      image_url: null,
      errorMessage: null,
      vehicles: [],
      uploading: false,
      paymentMethods: ['Corporate Card', 'Personal Cash'],
      jobs: ['Big Trees', 'Big Properties', 'Big Stumps'],
      organization: this.$store.state.organization
    }
  },
  computed: {
    vehicleOptions() {
      return objectOptionList(this.vehicles, [{ value: null, text: 'None'}])
    },
    categoryOptions() {
      return stringOptionList(['fuel', 'tools', 'repairs', 'travel', 'cheque', 'other', 'benefits']);
    },
    jobOptions() {
      return stringOptionList(this.jobs);
    },
    paymentMethodOptions() {
      return stringOptionList(this.paymentMethods);
    }
  },
  methods: {
    createReceipt() {
      this.errorMessage = null;
      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }

        if(!this.uploading && !this.image_url) {
          this.errorMessage = 'Please upload an image of the receipt';
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return
        }

        if(this.uploading && !this.image_url) {
          this.errorMessage = 'Please wait for upload to finish before submitting';
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return
        }

        let params = { receipt: {
          description: this.description,
          category: this.category,
          payment_method: this.paymentMethod,
          vehicle_id: this.vehicle_id,
          image_url: this.image_url,
          cost: this.cost
        }}

        if(this.organization.id == 1) {
          params.job = this.job;
        }

        this.axiosPost('/receipts', params).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('RECEIPT_UPDATED');
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
      this.category = 'fuel';
      this.paymentMethod = 'Personal Cash';
      this.job = 'Big Trees';
      this.cost = null;
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
