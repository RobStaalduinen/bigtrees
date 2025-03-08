<template>
  <div v-if="!creationComplete">
    <validation-observer ref="observer">
      <app-input-field
        v-model="name"
        label="Your Name"
        name="name"
        validationRules="required"
      />

      <app-input-field
        v-model="streetAddress"
        label="Street Address"
        name="street_address"
        validationRules="required"
      />

      <app-input-field
        v-model="email"
        label="Email Address"
        name="email"
        validationRules="required|"
      />

      <app-input-field
        v-model="phoneNumber"
        label="Phone Number"
        name="phone_number"
        validationRules="required"
      />

      <b-form-group label="Upload Images">
        <div class='pre-upload-label'>Please upload up to three images of your issue</div>
          <app-file-upload
            v-model='image_urls[0]'
            accept=".jpg, .jpeg, .png"
            bucketName='property-management-requests'
            @upload-status-changed='handleUploadStatus'
          ></app-file-upload>

          <app-file-upload
            v-model='image_urls[1]'
            accept=".jpg, .jpeg, .png"
            bucketName='property-management-requests'
            @upload-status-changed='handleUploadStatus'
          ></app-file-upload>

          <app-file-upload
            v-model='image_urls[2]'
            accept=".jpg, .jpeg, .png"
            bucketName='property-management-requests'
            @upload-status-changed='handleUploadStatus'
          ></app-file-upload> 
      </b-form-group>

      <app-select-field
        label='Issue Type'
        v-model='work_type'
        name='work_type'
        :options="workTypeOptions"
        validationRules='required'
      />

      <app-text-area
        v-model="description"
        label="Description"
        name="description"
        rows=4
      />
    </validation-observer>

    <span v-if="upload_error">Please wait until all images are finished uploading.</span>

    <!-- <b-button type='submit' block class='submit-button' @click="submit">Submit</b-button> -->
    <div class="submit-container">
      <app-submit-button :onSubmit="submit" label="Submit" />
    </div>
  </div>
  <div v-else>
      Thank you for submitting your request! We will be in touch shortly.
  </div>
</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  props: { 
    customer_shortname: {
      required: true
    }
  },
  data() {
    return {
      name: null,
      streetAddress: null,
      email: null,
      phoneNumber: null,
      description: null,
      work_type: 'tree_services',
      image_urls: [null, null, null],
      currently_uploading: false,
      upload_error: false,
      creationComplete: false
    }
  },
  methods: {
    handleUploadStatus(status) {
      this.currently_uploading = status;
    },
    submit() {
      this.upload_error = false;
      
      if(this.currently_uploading) {
        EventBus.$emit('FORM_VALIDATION_FAILED');
        this.upload_error = true;
        return;
      }
      let params = {
        customer_detail: {
          name: this.name,
          email: this.email,
          phone: this.phoneNumber,
          address_attributes: {
            street: this.streetAddress
          }
        },
        job: {
          job_type: this.work_type,
          description: this.description
        },
        site: {
          address_attributes: {
            street: this.streetAddress
          }
        },
        image_urls: this.image_urls
      }

      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }
        else {
          this.axiosPost(`/p/${this.customer_shortname}`, params)
            .then(response => {
              if(response.status === 200) {
                this.creationComplete = true
              }
            })
            .catch(error => {
              console.log(error);
            });
        }
      });
    }
  },
  computed: {
    workTypeOptions() {
      return [
        { value: 'tree_services', text: 'Tree Services' },
        { value: 'plumbing_and_water', text: 'Plumbing and Water' },
        { value: 'electrical_and_lighting', text: 'Electrical and Lighting' },
        { value: 'landscaping_and_garden_plants', text: 'Landscaping and Garden Plants' },
        { value: 'snow', text: 'Snow' },
        { value: 'windows_and_doors', text: 'Windows and Doors' },
        { value: 'flooring', text: 'Flooring' },
        { value: 'roof_and_siding', text: 'Roof and Siding' },
        { value: 'neighbours_and_neighbourhood', text: 'Neighbours and Neighbourhood' },
        { value: 'other', text: 'Other' }
      ]
    }
  },
}

</script>

<style>
  .submit-button {
    color: white;
    font-size: 1.1em;
  }

  .pre-upload-label {
    font-size: 0.8em;
    margin-top: -8px;
    margin-bottom: 10px;
  }

  .submit-container {
    display: flex;
    justify-content: center;
  }

</style>