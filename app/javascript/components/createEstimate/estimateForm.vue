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

      <estimate-form-section header='Tasks & Images'>
        <estimate-task-form @input='onTasksImagesChange'></estimate-task-form>
      </estimate-form-section>

      <estimate-form-section header='Costs'>
        <estimate-costs-form @input='(payload) => { this.costs = payload }'></estimate-costs-form>
      </estimate-form-section>

      <estimate-form-section header='Equipment and Tool Requirements'>
        <estimate-tool-form
          v-model='toolSelection'
        ></estimate-tool-form>
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
import CostsForm from './costsForm';
import FormSection from './formSection'
import ToolForm from './equipmentForm';
import NotesForm from './notesForm';

export default {
  components: {
    'app-customer-form': CustomerForm,
    'app-address-form': AddressForm,
    'estimate-site-questions': SiteQuestions,
    'estimate-task-form': TaskForm,
    'estimate-costs-form': CostsForm,
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
      uncategorizedImages: [],
      costs: [],
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
    onTasksImagesChange(payload) {
      this.tasks = payload.tasks;
      this.uncategorizedImages = payload.uncategorizedImages;
    },
    onSubmit() {

      this.submitForm();

      // this.validationErrors = false;
      // this.$refs.observer.validate().then(success => {
      //   if (!success) {
      //     this.validationErrorMessage = 'Please check all fields and try again'
      //     this.validationErrors = true;
      //     return;
      //   }
      //   var allUploadsComplete = this.tasks.every(task => { return task.image == undefined || task.image.uploadCompleted == true })
      //   if(!allUploadsComplete) {
      //       this.validationErrorMessage = 'Wait for image uploads to finish and try again'
      //       this.validationErrors = true;
      //       return;
      //   }

      //   this.submitForm();
      // })
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

        // Costs are now standalone invoice line items, no longer tied to tasks.
        // Drop blank rows (e.g. the untouched starter row) so we don't persist
        // empty costs.
        const costs = this.costs.filter(cost => cost.amount != null && cost.amount !== '');
        const costRequest = costs.length > 0
          ? this.axiosPost(`/estimates/${estimateId}/costs`, { costs })
          : Promise.resolve();

        costRequest.then(() => {
          // Trees are created without images; the durable queue associates each
          // uploaded image to its tree in the background via resolveTarget.
          var treeOptions = {
            estimate_id: estimateId,
            trees: this.tasks.map(task => ({ description: task.description }))
          }

          this.axiosPost('/trees/bulk_create', treeOptions).then(response => {
            // Persist each job's resolved target before navigating, so the
            // background association survives the full page reload below.
            this.resolveImageTargets(estimateId, response.data.tree_ids).then(() => {
              window.location.href = `/admin/estimates/${estimateId}`
            })
          })
        })
      })
    },
    // Rewire pending upload jobs to their real target before navigating, so the
    // placeholder + URL-fill complete in the background. Task images attach to
    // the tree bulk_create returned (in task order); uncategorized images
    // attach to the estimate only (tree_id null).
    resolveImageTargets(estimateId, treeIds) {
      const promises = [];

      if (Array.isArray(treeIds) && treeIds.length === this.tasks.length) {
        this.tasks.forEach((task, index) => {
          const jobs = Array.isArray(task.images) ? task.images : [];
          jobs.forEach(job => {
            promises.push(this.$uploads.resolveTarget(job.id, {
              type: 'tree_image',
              estimate_id: estimateId,
              tree_id: treeIds[index]
            }));
          });
        });
      } else {
        // Guard against slot→tree mismaps; skip task association rather than
        // risk attaching images to the wrong tree.
        console.error('bulk_create returned', treeIds && treeIds.length, 'tree_ids for', this.tasks.length, 'tasks');
      }

      const uncategorized = Array.isArray(this.uncategorizedImages) ? this.uncategorizedImages : [];
      uncategorized.forEach(job => {
        promises.push(this.$uploads.resolveTarget(job.id, {
          type: 'tree_image',
          estimate_id: estimateId,
          tree_id: null
        }));
      });

      return Promise.all(promises);
    }
  },
  mounted() {
    var query = this.$route.query;
    if(query.customer_id) {
      this.axiosGet(`/customers/${query.customer_id}`).then(response => {
        if(response.data.customer.id == query.customer_id) {
          var customer = response.data.customer;
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
