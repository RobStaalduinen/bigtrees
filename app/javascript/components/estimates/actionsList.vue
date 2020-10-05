<template>
  <b-nav-item-dropdown
    id="actions-dropdown"
    text="Actions"
    right
  >
    <b-dropdown-item v-if="!estimate.is_unknown" :href='`/estimates/${estimate.id}/quote_mailouts/new?mail_type=followup`'>
      Unknown
    </b-dropdown-item>

    <b-dropdown-item v-if="estimate.is_unknown" @click='reactivate()'>
      Reactivate
    </b-dropdown-item>
    
    <b-dropdown-item v-if="canSchedule()" :href='`/estimates/${estimate.id}/edit?form_option=set_work_date`'>
      Schedule
    </b-dropdown-item>

    <b-dropdown-item v-if="estimate.status == 'final_invoice_sent'" :href='`/invoices/${estimate.invoice.id}/edit?form_option=finalize_payment`'>
      Set Payment
    </b-dropdown-item>
  </b-nav-item-dropdown>
</template>

<script>
export default {
  props: {
    estimate: {
      type: Object,
      required: true
    }
  },
  methods: {
    canSchedule(){
      return this.estimate.status == 'quote_sent';
    },
    reactivate() {
      var params = { estimate: { is_unknown: false } };
      this.axiosPut(`/estimates/${this.estimate.id}`, params).then(response => {
        this.$emit('estimateChanged', null);
      });
    }
  }
}
</script>

<style scoped>
  #actions-dropdown {
    display: block;
  }

  #actions-dropdown >>> a {
    padding: 6px 12px;
  }
</style>
