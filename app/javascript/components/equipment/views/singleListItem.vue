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
        <!-- {{ equipmentRequest.category }} - {{ equipmentRequest.description }} -->
      </template>

      <template v-slot:collapsed>
        <app-collapsable-action-bar>
          <template v-slot:content>
            <app-action-bar-item name='Resolve' />
            <app-action-bar-item name='Details' :onClick='toggleModal' />
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

        <div v-if='equipmentRequest.image_path' class='modal-row'>
          <b-img fluid :src='equipmentRequest.image_path' />
        </div>
      </div>

      <template v-slot:modal-footer>
        <b-button block class='submit-button' @click='close()'>Done</b-button>
      </template>
    </b-modal>

  </section>
</template>

<script>
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
</style>
