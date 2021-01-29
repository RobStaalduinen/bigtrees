<template>
  <app-right-sidebar :id='id' title='Edit Invoice' submitText='Save' :onSubmit='updateInvoice'>
    <template v-slot:content>
      <app-invoice-form v-model='invoice'></app-invoice-form>
    </template>
  </app-right-sidebar>
</template>

<script>
import InvoiceForm from '../forms/full';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-invoice-form': InvoiceForm
  },
  props: {
    id: {
      required: true
    },
    estimate: {
      required: true
    }
  },
  data() {
    return {
      invoice: { ...this.estimate.invoice }
    }
  },
  methods: {
    updateInvoice() {
      var params = { invoice: this.invoice }
      this.axiosPut(`/invoices/${this.estimate.invoice.id}`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('ESTIMATE_UPDATED', { invoice: response.data.invoice });
      })
    }
  }
}
</script>

<style scoped>

</style>
