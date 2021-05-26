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
            <!-- <app-action-bar-item
              name='Send to Team'
              icon='envelope'
              :onClick='toggleSend'
              v-if='hasPermission("equipment_requests", "update")'
            /> -->
            <app-action-bar-item
              name='Mark as Repaid'
              icon='check-circle'
              v-if='canRepay()'
              :onClick='approveReceipt'
            />
            <app-action-bar-item
              name='Details'
              icon='clipboard-plus'
            />
          </template>
        </app-collapsable-action-bar>
      </template>
    </app-collapsable-list-item>

    <!-- <b-modal :id='`eq-modal-${equipmentRequest.id}`' centered title='Details'>
      <div class='modal-internal'>
        <div class='modal-row'><b>Submitted At:</b> {{ equipmentRequest.submitted_at }}</div>
        <div class='modal-row'><b>Submitter:</b> {{ equipmentRequest.arborist.name }}</div>
        <div class='modal-row'><b>Description:</b> {{ equipmentRequest.description }}</div>
        <div class='modal-row'><b>Vehicle:</b> {{ vehicleName() }}</div>
        <div class='modal-row' v-if='equipmentRequest.resolution_notes'><b>Resolution Notes:</b>
          {{ equipmentRequest.resolution_notes }}
        </div>

        <div v-if='equipmentRequest.image_path' class='modal-row'>
          <b-img fluid :src='equipmentRequest.image_path' />
        </div>

        <div class='modal-button-row'>
          <b-button
            class='inverse-button modal-button'
            @click='toggleSend'
            v-if='hasPermission("equipment_requests", "update")'
          >
            Send to Team
          </b-button>

          <b-button
            class='inverse-button modal-button'
            @click='toggleResolve'
            v-if='equipmentRequest.state == "submitted" && hasPermission("equipment_requests", "update")'
          >
            Resolve
          </b-button>
        </div>
      </div>

      <template v-slot:modal-footer>
        <b-button block class='submit-button' @click='close()'>Done</b-button>
      </template>
    </b-modal> -->

  </section>
</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  props: {
    'receipt': {
      required: true,
      type: Object
    }
  },
  methods: {
    toggleResolve() {
      // this.$bvModal.hide(`eq-modal-${this.equipmentRequest.id}`);
      // EventBus.$emit('RESOLVE_EQUIPMENT_REQUEST', this.equipmentRequest);
    },
    toggleSend() {
      // this.$bvModal.hide(`eq-modal-${this.equipmentRequest.id}`);
      // EventBus.$emit('SEND_EQUIPMENT_REQUEST', this.equipmentRequest);
    },
    approveReceipt() {
      this.axiosPost(`/receipts/${this.receipt.id}/approve`).then(response => {
        EventBus.$emit('RECEIPT_UPDATED');
      })
    },
    canRepay() {
      return this.receipt.state == 'pending' && this.hasPermission("receipts", "admin")
    }
  }
}
</script>

<style scoped>
  .receipt {
    font-size: 12px
  }
</style>
