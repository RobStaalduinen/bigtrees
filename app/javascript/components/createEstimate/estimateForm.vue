<template>
  <validation-observer ref="observer">
    <b-form @submit.prevent="onSubmit">
      <estimate-form-section header='Customer'>
        <app-customer-form v-model='customer'> </app-customer-form>
      </estimate-form-section>

      <estimate-form-section header='Address'>
        <app-address-form
          v-model='addresses'
          :initialSite='initialAddresses.site'
          :initialBilling='initialAddresses.billing'
          @addressesChanged='(payload) => { addresses = payload }'
        >
        </app-address-form>
      </estimate-form-section>

      <estimate-form-section header='Equipment and Tool Requirements'>
        <estimate-tool-form
          v-model='toolSelection'
        ></estimate-tool-form>
      </estimate-form-section>

      <estimate-form-section header='Tasks'>
        <estimate-task-form :value='tasks' @input='(payload) => { this.tasks = [...payload] }'></estimate-task-form>
      </estimate-form-section>

      <estimate-form-section header='Notes'>
        <estimate-notes-form v-model='notes'></estimate-notes-form>
      </estimate-form-section>

      <span class='submit-error' v-if='validationErrors'>{{ validationErrorMessage }}</span>
      <b-button type='submit' block class='submit-button'>Submit</b-button>
    </b-form>
  </validation-observer>
</template>

<script>
import CustomerForm from './customerForm';
import AddressForm from './addressForm';
import SiteQuestions from './siteQuestions';
import TaskForm from './taskForm';
import FormSection from './formSection'
import ToolForm from '@/components/tools/forms/mutliSelect';
import NotesForm from './notesForm';

export default {
  components: {
    'app-customer-form': CustomerForm,
    'app-address-form': AddressForm,
    'estimate-site-questions': SiteQuestions,
    'estimate-task-form': TaskForm,
    'estimate-form-section': FormSection,
    'estimate-tool-form': ToolForm,
    'estimate-notes-form': NotesForm
  },
  data() {
    return {
      customer: {},
      addresses: {},
      site: {},
      tasks: [],
      costs: [],
      treeImages: [],
      toolSelection: [],
      notes: [],
      validationErrors: false,
      customerId: null,
      siteId: null,
      estimateId: null,
      validationErrorMessage: 'Please check all fields and try again',
      initialAddresses: { site: null, billing: null},
    }
  },
  methods: {
    onSubmit() {
      this.validationErrors = false;
      this.$refs.observer.validate().then(success => {
        if (!success) {
          this.validationErrorMessage = 'Please check all fields and try again'
          this.validationErrors = true;
          return;
        }
        var allUploadsComplete = this.tasks.every(task => { return task.image == undefined || task.image.uploadCompleted == true })
        if(!allUploadsComplete) {
            this.validationErrorMessage = 'Wait for image uploads to finish and try again'
            this.validationErrors = true;
            return;
        }

        this.submitForm();
      })
    },
    submitForm() {
      let customerAttributes = { ...this.customer }
      if(this.addresses.billingAddress != null) {
        customerAttributes.address_attributes = this.addresses.billingAddress
      }

      let siteAttributes = { ...this.site }
      siteAttributes.address_attributes = this.addresses.siteAddress

      let equipmentAssignments = this.toolSelection.map( selection => {
        return {
          vehicle_id: selection
        }
      })

      let options = {
        customer: customerAttributes,
        site: siteAttributes,
        estimate: {
          tree_quantity: 1,
          submission_completed: true,
          equipment_assignments_attributes: equipmentAssignments
        }
      }

      if (this.notes.length > 0) {
        options.estimate.notes_attributes = this.notes.map( note => {
          let note_attr = {}
          note_attr.content = note.content

          if (note.fileUrl != null) {
            note_attr.image_attributes = { image_url: note.fileUrl }
          }

          return note_attr
        })
      }

      this.axiosPost('/estimates', options).then(response => {
        var estimateId = response.data.estimate_id
        let costOptions = {
          costs: this.tasks.map(task => { return task.cost })
        }
        this.axiosPost(`/estimates/${estimateId}/costs`, costOptions).then(response => {
          let trees = this.tasks.map(task => {
            return {
              tree_images_attributes: this.getTreeImageAttributes(task)
            }
          })
          var treeOptions = {
            estimate_id: estimateId,
            trees: trees
          }

          this.axiosPost('/trees/bulk_create', treeOptions).then(response => {
            window.location.href = `/admin/estimates/${estimateId}`
          })
        })
      })
    },
    getTreeImageAttributes(task) {
        if(task.image != undefined && task.image != null) {
          return [{ image_url: task.image.url }];
        }
        else {
          return [];
        }
    }
  },
  mounted() {
    var query = this.$route.query;
    if(query.customer_id) {
      this.axiosGet(`/customers/${query.customer_id}`).then(response => {
        if(response.data.id == query.customer_id) {
          var customer = response.data;
          this.customer = {
            id: customer.id,
            name: customer.name,
            email: customer.email,
            phone: customer.phone
          }

          var addresses = {}
          if(customer.address) {
            addresses.billing = { ...customer.address };
          }

          if(customer.site_address) {
            addresses.site = { ...customer.site_address }
          }

          this.initialAddresses = addresses;
        }
      })
    }
  }
}
</script>

<style scoped>

</style>
