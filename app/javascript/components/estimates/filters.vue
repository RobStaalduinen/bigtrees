<template>
  <b-modal :id='modalId' centered title='Filters'>
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
  </b-modal>
</template>

<script>
export default {
  props: {
    modalId: {
      required: true,
      type: String
    },
    value: {
      type: Object,
      default: function() {
        return {
          status: 'all',
          createdAfter: 'forever'
        }
      }
    }
  },
  data() {
    return {
      statusOptions: [
        { value: 'all', text: 'All' },
        { value: 'needs_pricing', text: 'Needs Pricing' },
        { value: 'awaiting_response', text: 'Awaiting Customer Response' },
        { value: 'to_pay', text: 'To Pay' },
        { value: 'scheduled', text: 'Approved and Scheduled' },
        { value: 'unknown', text: 'Unknown' }
      ],
      createdOptions: [
        { value: 'one_week', text: 'One Week' },
        { value: 'one_month', text: 'One month' },
        { value: 'six_months', text: 'Six Months' },
        { value: 'forever', text: 'Forever' }
      ],
      status: null,
      createdAfter: null
    }

  },
  mounted() {
    this.status = this.value.status;
    this.createdAfter = this.value.createdAfter;
  },
  methods: {
    close(){
      this.$bvModal.hide(this.modalId);
    },
    changeFilters() {
      this.$emit('input', { status: this.status, createdAfter: this.createdAfter });
    }
  },
  watch: {
    value: function() {
      this.status = this.value.status;
      this.createdAfter = this.value.createdAfter;
    }
  }
}
</script>

<style>

</style>
