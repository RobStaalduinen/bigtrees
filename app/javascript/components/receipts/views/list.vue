<template>
  <div>
    <app-receipt-summaries
      :summaries='summaries'
      v-if='hasPermission("receipts", "admin")'
    />

    <hr>

    <div class='request-list'>
      <app-select-field
        label='Status'
        v-model='status'
        name='status'
        :options="options"
      />

      <div class='receipt-list-container'>
        <app-loading-overlay v-if='loadingReceipts'></app-loading-overlay>

        <div
          v-for='receipt in receipts'
          :key='receipt.id'
          class='receipt-container'
        >
          <app-receipt
            :receipt='receipt'
            :toggleDetails='toggleModal'
            :toggleReject='toggleReject'
            :approveReceipt='approveReceipt'
          />
        </div>
      </div>

      <b-modal :id='`receipt-modal`' centered title='Details'>
        <div class='modal-internal' v-if='displayedReceipt'>

          <div v-if='displayedReceipt.image_path' class='modal-row'>
            <b-img fluid :src='displayedReceipt.image_path' />
          </div>

          <div class='modal-row'><b>Date:</b> {{ displayedReceipt.date }}</div>
          <div class='modal-row'><b>Cost:</b> {{ `$ ${displayedReceipt.cost}` }}</div>
          <div class='modal-row'><b>Category:</b> {{ capitalize(displayedReceipt.category) }}</div>
          <div class='modal-row'><b>Job:</b> {{ displayedReceipt.job }}</div>
          <div class='modal-row'><b>Vehicle:</b> {{ displayedReceipt.vehicle ? displayedReceipt.vehicle.name : 'None' }}</div>
          <div class='modal-row'><b>Payment Method:</b> {{ displayedReceipt.payment_method }}</div>
          <div class='modal-row' v-if='displayedReceipt.rejection_reason'
            ><b>Rejection Reason:</b> {{ displayedReceipt.rejection_reason }}
          </div>

        </div>

        <template v-slot:modal-footer>
          <div class='modal-row'>
            <b-button
              class='inverse-button modal-button'
              v-if='receiptInfo.canReject() && hasPermission("receipts", "admin")'
              @click='() => toggleReject(displayedReceipt.id)'
            >
              Reject
            </b-button>
            <b-button
              class='inverse-button modal-button'
              v-if='receiptInfo.canApprove() && hasPermission("receipts", "admin")'
              @click='() => approveReceipt(displayedReceipt.id)'
            >
              Mark as Repaid
            </b-button>
          </div>
          <div class='modal-row'>
            <b-button block class='submit-button' @click='close()'>Done</b-button>
          </div>
        </template>
      </b-modal>

      <app-reject-receipt
        :receipt="displayedReceipt"
        id='reject-receipt'
      ></app-reject-receipt>
    </div>
  </div>
</template>

<script>
import EventBus from '@/store/eventBus';
import SingleReceipt from './singleListItem';
import { stringHelper } from '@/utils/stringUtils';
import { Receipt } from '@/models';
import RejectReceipt from '../actions/reject';
import Summaries from './summaries';

export default {
  components: {
    'app-receipt': SingleReceipt,
    'app-reject-receipt': RejectReceipt,
    'app-receipt-summaries': Summaries
  },
  mixins: [stringHelper],
  data() {
    return {
      receipts: [],
      loadingReceipts: false,
      summaries: {},
      status: 'pending',
      options: [
        { text: 'Pending', value: 'pending' },
        { text: 'Repaid', value: 'approved' },
        { text: 'Rejected', value: 'rejected' }
      ],
      displayedReceipt: null
    }
  },
  methods: {
    retrieveReceipts() {
      this.loadingReceipts = true;
      this.axiosGet(`/receipts?state=${this.status}`).then(response => {
        this.receipts = response.data.receipts;
        this.loadingReceipts = false;
      })
    },
    retrieveSummaries() {
      this.axiosGet(`/receipts/summaries`).then(response => {
        console.log(response.data);
        this.summaries = response.data;
      })
    },
    toggleModal(receipt_id) {
      this.displayedReceipt = this.receipts.filter(receipt => receipt.id == receipt_id)[0];
      this.$bvModal.show(`receipt-modal`);
    },
    approveReceipt(receipt_id) {
      this.axiosPost(`/receipts/${receipt_id}/approve`).then(response => {
        EventBus.$emit('RECEIPT_UPDATED');
        this.$bvModal.hide(`receipt-modal`);
      })
    },
    toggleReject(receipt_id) {
      this.displayedReceipt = this.receipts.filter(receipt => receipt.id == receipt_id)[0];
      this.$bvModal.hide(`receipt-modal`);
      this.$root.$emit('bv::toggle::collapse', 'reject-receipt');
    },
    close() {
      this.$bvModal.hide(`receipt-modal`);
    }
  },
  computed: {
    receiptInfo() {
      return new Receipt(this.displayedReceipt);
    }
  },
  mounted() {
    this.retrieveReceipts();
    this.retrieveSummaries();

    EventBus.$on('RECEIPT_UPDATED', () => {
      this.retrieveReceipts();
      this.retrieveSummaries();
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
  .receipt-container {
    margin-top: 8px;
  }

  .receipt-list-container {
    position: relative;
    width: 100%;
    min-height: 200px;
  }

  .modal-internal {
    max-height: 500px;
    overflow: scroll;
    font-size: 14px;
  }

  .modal-row {
    margin-top: 4px;
    width: 100%;
  }

  .modal-button-row {
    display: flex;
    justify-content: space-between;
    margin-top: 16px;
  }

  .modal-button {
    width: 49%;
  }
</style>
