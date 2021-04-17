<template>
  <section>
    <app-collapsable-list-item :id='`equipment-request-${equipmentRequest.id}`' class='equipment-request'>
      <template v-slot:content>
        <div class='equipment-request-header'>
          <div class='equipment-request-time'>
            {{ equipmentRequest.submitted_at }}
          </div>

          <div class='equipment-request-category'>
            {{ equipmentRequest.category }}
          </div>
        </div>

        <div class='equipment-request-content'>
          <div class='equipment-request-content-row'><b>Vehicle: </b> {{ vehicleName() }}</div>
          <div class='equipment-request-content-row'><b>Description: </b> {{ equipmentRequest.description }}</div>
        </div>
      </template>

      <template v-slot:collapsed>
        <app-collapsable-action-bar>
          <template v-slot:content>
            <app-action-bar-item
              name='Send to Team'
              icon='envelope'
              :onClick='toggleSend'
              v-if='admin'
            />
            <app-action-bar-item
              name='Resolve'
              icon='check-circle'
              :onClick='toggleResolve'
              v-if='equipmentRequest.state == "submitted" && admin'
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
            v-if='admin'
          >
            Send to Team
          </b-button>

          <b-button
            class='inverse-button modal-button'
            @click='toggleResolve'
            v-if='equipmentRequest.state == "submitted" && admin'
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
    toggleSend() {
      this.$bvModal.hide(`eq-modal-${this.equipmentRequest.id}`);
      EventBus.$emit('SEND_EQUIPMENT_REQUEST', this.equipmentRequest);
    },
    close() {
      this.$bvModal.hide(`eq-modal-${this.equipmentRequest.id}`);
    }
  },
  computed: {
    admin() {
      return this.$store.state.user.admin;
    },
  }
}
</script>

<style scoped>
  .equipment-request {
    font-size: 12px
  }

  .equipment-request-header {
    display: flex;
    justify-content: space-between;
    width: 100%;

    border-width: 0 0 1px 0;
    border-style: solid;
    border-color: lightgray;
  }

  .equipment-request-time {
    padding: 4px;
  }

  .equipment-request-category{
    padding: 4px;
    color: white;
    background-color: var(--secondary-red);
    min-width: 20%;
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .equipment-request-content{
    display: flex;
    flex-direction: column;
    padding: 4px;
  }

  .equipment-request-content-row {
    margin-top: 4px;
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
