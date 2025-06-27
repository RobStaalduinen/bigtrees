<template>
  <!-- <b-modal :id='modalId' centered title='Filters'>
    <b-form-group
      label="Status"
      label-for="status"
    >
      <b-form-select v-model="status" :options="statusOptions" @change="changeFilters()"></b-form-select>
    </b-form-group>

    <b-form-group
      label="Estimate Age"
      label-for="created_after"
    >
      <b-form-select v-model="createdAfter" :options="createdOptions" @change="changeFilters()"></b-form-select>
    </b-form-group>

    <template v-slot:modal-footer>
      <b-button block class='submit-button' @click='close()'>Done</b-button>
    </template>
  </b-modal> -->

  <app-right-sidebar
    :id="id"
    title="Filters"
    submitText="Done"
    :onSubmit="close"
  >
    <template v-slot:content>
      <b-form-group
        label="Assigned To"
        label-for="assigned_to"
      >
        <b-form-select v-model="assignedTo" :options="[{ value: 'everyone', text: 'Everyone' }, { value: 'me', text: 'Me' }]"  @change="changeFilters()" />
      </b-form-group>

      <b-form-group
        label="Status"
        label-for="status"
      >
        <b-form-select v-model="status" :options="statusOptions" @change="changeFilters()"></b-form-select>
      </b-form-group>

      <b-form-group
        label="Estimate Age"
        label-for="created_after"
      >
        <b-form-select v-model="createdAfter" :options="createdOptions" @change="changeFilters()"></b-form-select>
      </b-form-group>

      <app-tag-selector
        id="tag-selector"
        v-model="tagIds"
      />
    </template>
  </app-right-sidebar>
</template>

<script>
import TagSelector from '@/components/tags/views/selector.vue'

export default {
  components: {
    'app-tag-selector': TagSelector
  },
  props: {
    id: {
      required: true,
      type: String
    },
    value: {
      type: Object,
      default: function() {
        return {
          status: 'active',
          createdAfter: 'forever',
          tagIds: []
        }
      }
    }
  },
  data() {
    return {
      statusOptions: [
        { value: 'all', text: 'All' },
        { value: 'active', text: 'Active' },
        { value: 'completed', text: 'Completed' },
        { value: 'on_hold', text: 'On Hold' },
        { value: 'pre_quote', text: 'Quote Needed' },
        { value: 'awaiting_response', text: 'Awaiting Customer Response' },
        { value: 'to_pay', text: 'To Pay' },
        { value: 'scheduled', text: 'Approved and Scheduled' },
        { value: 'unknown', text: 'Unknown' },
        { value: 'cancelled', text: 'Cancelled' }
      ],
      createdOptions: [
        { value: 'one_week', text: 'One Week' },
        { value: 'one_month', text: 'One month' },
        { value: 'six_months', text: 'Six Months' },
        { value: 'one_year', text: 'One Year' },
        { value: 'forever', text: 'Forever' }
      ],
      status: null,
      createdAfter: null,
      tagIds: [],
      assignedTo: 'everyone'
    }

  },
  mounted() {
    this.tagIds = this.value.tagIds || [];
    this.assignedTo = this.value.assignedTo || 'everyone';
    this.status = this.value.status;
    this.createdAfter = this.value.createdAfter;
  },
  methods: {
    close(){
      // this.$bvModal.hide(this.modalId);
      this.$root.$emit('bv::toggle::collapse', this.id);
    },
    changeFilters() {
      this.$emit('input', this.filterObject());
      // localStorage.setItem('estimateFilterStatus', JSON.stringify(this.filterObject()));
    },
    filterObject() {
      return { status: this.status, createdAfter: this.createdAfter, tagIds: this.tagIds, assignedTo: this.assignedTo };
    }
  },
  watch: {
    value() {
      this.status = this.value.status;
      this.createdAfter = this.value.createdAfter;
      this.tagIds = this.value.tagIds || [];
      this.assignedTo = this.value.assignedTo || 'everyone';
    },
    tagIds() {
      this.$emit('input', this.filterObject());
      console.log('Tag IDs changed:', this.tagIds);
    }
  }
}
</script>

<style>

</style>
