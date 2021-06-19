<template>
  <page-template>
    <app-header title='Receipts'>
      <template v-slot:header-right>
        <a v-b-toggle.create-equipment-request v-if='hasPermission("receipts", "create")'>
          New
        </a>
      </template>
    </app-header>

    <app-receipt-list></app-receipt-list>

    <app-create-receipt
      id='create-equipment-request'
      v-if='hasPermission("receipts", "create")'
    ></app-create-receipt>
  </page-template>
</template>

<script>
import ReceiptList from '@/components/receipts/views/list';
import CreateReceipt from '@/components/receipts/actions/create'
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-create-receipt': CreateReceipt,
    'app-receipt-list': ReceiptList
  },
  data() {
    return {
      selectedRequest: null
    }
  },
  mounted() {
    // EventBus.$on('RESOLVE_EQUIPMENT_REQUEST', (request) => {
    //   this.selectedRequest = request;
    //   this.$root.$emit('bv::toggle::collapse', 'resolve-equipment-request');
    // })

    // EventBus.$on('SEND_EQUIPMENT_REQUEST', (request) => {
    //   this.selectedRequest = request;
    //   this.$root.$emit('bv::toggle::collapse', 'send-equipment-request');
    // })
  }
}
</script>

<style scoped>

</style>
