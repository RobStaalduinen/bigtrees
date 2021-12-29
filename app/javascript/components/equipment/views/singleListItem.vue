<template>
  <section>
    <app-collapsable-list-item :id='`equipment-request-${equipmentRequest.id}`' class='equipment-request'>
      <template v-slot:content>
        <div class='list-item-header'>
          <div class='list-item-header-left'>
            {{ equipmentRequest.submitted_at }}
          </div>

          <div class='list-item-header-highlight'>
            {{ equipmentRequest.category }}
          </div>
        </div>

        <div class='list-item-content'>
          <div v-if='equipmentRequest.mechanic' class='list-item-content-row'>
            <b>Mechanic: </b> {{ equipmentRequest.mechanic.name }}
          </div>
          <div class='list-item-content-row'><b>Vehicle: </b> {{ vehicleName() }}</div>
          <div class='list-item-content-row'><b>Description: </b> {{ equipmentRequest.description }}</div>
        </div>
      </template>

      <template v-slot:collapsed>
        <app-collapsable-action-bar>
          <template v-slot:content>
            <app-action-bar-item
              name='Send to Team'
              icon='envelope'
              :onClick='toggleSend'
              v-if='hasPermission("equipment_requests", "update")'
            />
            <app-action-bar-item
              name='Resolve'
              icon='check-circle'
              :onClick='toggleResolve'
              v-if='canResolve() && hasPermission("equipment_requests", "update")'
            />
            <app-action-bar-item
              name='Assign'
              icon='person-badge'
              :onClick='toggleAssign'
              v-if='equipmentRequest.state == "submitted" && hasPermission("equipment_requests", "update")'
            />
            <app-action-bar-item
              name='Edit'
              icon='pencil-square'
              :onClick='toggleEdit'
              v-if='hasPermission("equipment_requests", "create")'
            />
            <app-action-bar-item
              name='Details'
              icon='clipboard-plus'
              :onClick='toggleModal'
            />
          </template>
        </app-collapsable-action-bar>
      </template>
    </app-collapsable-list-item>

    <b-modal :id='`eq-modal-${equipmentRequest.id}`' centered title='Details'>
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
            @click='toggleAssign'
            v-if='equipmentRequest.state == "submitted" && hasPermission("equipment_requests", "update")'
          >
            Assign
          </b-button>

          <b-button
            class='inverse-button modal-button'
            @click='toggleResolve'
            v-if='equipmentRequest.state == "assigned" && hasPermission("equipment_requests", "update")'
          >
            Resolve
          </b-button>
        </div>
      </div>

      <template v-slot:modal-footer>
        <b-button block class='submit-button' @click='close()'>Done</b-button>
      </template>
    </b-modal>

  </section>
</template>

<script>
import ResolveRequest from '@/components/equipment/actions/resolve';
import EventBus from '@/store/eventBus';

export default {
  props: {
    'equipmentRequest': {
      required: true,
      type: Object
    }
  },
  methods: {
    vehicleName() {
      if(this.equipmentRequest.vehicle == null) {
        return 'None'
      }

      return this.equipmentRequest.vehicle.name;
    },
    toggleModal() {
      this.$bvModal.show(`eq-modal-${this.equipmentRequest.id}`);
    },
    toggleResolve() {
      this.$bvModal.hide(`eq-modal-${this.equipmentRequest.id}`);
      EventBus.$emit('RESOLVE_EQUIPMENT_REQUEST', this.equipmentRequest);
    },
    toggleAssign() {
      this.$bvModal.hide(`eq-modal-${this.equipmentRequest.id}`);
      EventBus.$emit('ASSIGN_EQUIPMENT_REQUEST', this.equipmentRequest);
    },
    toggleEdit() {
      this.$bvModal.hide(`eq-modal-${this.equipmentRequest.id}`);
      EventBus.$emit('EDIT_EQUIPMENT_REQUEST', this.equipmentRequest);
    },
    toggleSend() {
      this.$bvModal.hide(`eq-modal-${this.equipmentRequest.id}`);
      EventBus.$emit('SEND_EQUIPMENT_REQUEST', this.equipmentRequest);
    },
    canResolve() {
      return this.equipmentRequest.state == "submitted" || this.equipmentRequest.state == 'assigned'
    },
    close() {
      this.$bvModal.hide(`eq-modal-${this.equipmentRequest.id}`);
    }
  }
}
</script>

<style scoped>
  .equipment-request {
    font-size: 12px
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
