<template>
  <section>
    <app-collapsable-list-item :id='`receipt-${receipt.id}`' class='receipt'>
      <template v-slot:content>
        <div class='list-item-header'>
          <div class='list-item-header-left'>
            {{ receipt.date }}
          </div>

          <div class='list-item-header-highlight'>
            {{ receipt.category }}
          </div>
        </div>

        <div class='list-item-content'>
          <div class='list-item-content-row'><b>Submitter: </b> {{ receipt.arborist.name }}</div>
          <div class='list-item-content-row'><b>Cost: </b> {{ `$ ${receipt.cost}` }}</div>
          <div class='list-item-content-row'><b>Description: </b> {{ receipt.description }}</div>
        </div>
      </template>

      <template v-slot:collapsed>
        <app-collapsable-action-bar>
          <template v-slot:content>
            <app-action-bar-item
              name='Reject Receipt'
              icon='x-circle'
              v-if="receiptInfo.canReject() && hasPermission('receipts', 'admin')"
              :onClick='() => toggleReject(receipt.id)'
            ></app-action-bar-item>
            <app-action-bar-item
              name='Mark as Repaid'
              icon='check-circle'
              v-if="receiptInfo.canApprove() && hasPermission('receipts', 'admin')"
              :onClick='approve'
            />
            <app-action-bar-item
              name='Details'
              icon='clipboard-plus'
              :onClick='() => toggleDetails(receipt.id)'
            />
          </template>
        </app-collapsable-action-bar>
      </template>
    </app-collapsable-list-item>
  </section>
</template>

<script>
import EventBus from '@/store/eventBus';
import { Receipt } from '@/models';

export default {
  props: {
    'receipt': {
      required: true,
      type: Object
    },
    'toggleDetails': {
      required: true,
      type: Function
    },
    'toggleReject': {
      required: true,
      type: Function
    },
    'approveReceipt': {
      required: true,
      type: Function
    }
  },
  computed: {
    receiptInfo() {
      return new Receipt(this.receipt);
    }
  },
  methods: {
    approve() {
      this.approveReceipt(this.receipt.id);
    }
  }
}
</script>

<style scoped>
  .receipt {
    font-size: 12px
  }
</style>
