<template>
  <div class='request-list'>
    <app-select-field
      label='Status'
      v-model='status'
      name='status'
      :options="options"
    />

    <div v-for='receipt in receipts' :key='receipt.id'>
      <app-receipt
        :receipt='receipt'
      />
    </div>
  </div>
</template>

<script>
import EventBus from '@/store/eventBus';
import SingleReceipt from './singleListItem';

export default {
  components: {
    'app-receipt': SingleReceipt
  },
  data() {
    return {
      receipts: [],
      status: 'pending',
      options: [
        { text: 'Pending', value: 'pending' },
        { text: 'Approved', value: 'approved' },
        { text: 'Rejected', value: 'rejected' }
      ]
    }
  },
  methods: {
    retrieveReceipts() {
      this.axiosGet(`/receipts?state=${this.status}`).then(response => {
        this.receipts = response.data.receipts
        console.log(response.data);
      })
    },
    toggleModal(receipt_id) {

    }
  },
  mounted() {
    this.retrieveReceipts();

    EventBus.$on('RECEIPT_UPDATED', () => {
      this.retrieveReceipts();
    })
  },
  watch: {
    status() {
      this.retrieveReceipts();
    }
  }
}
</script>

<style scoped>
  .single-request-container {
    margin-top: 8px;
  }
</style>
