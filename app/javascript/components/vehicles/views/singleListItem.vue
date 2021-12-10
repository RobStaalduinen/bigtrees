<template>
  <section>
    <app-collapsable-list-item :id='`vehicle-${vehicle.id}`' class='vehicle'>
      <template v-slot:content>
        <div class='list-item-header'>
          <div class='list-item-header-left'>
            <b>{{ vehicle.name }}</b>
          </div>
        </div>

        <div class='list-item-content'>
          <div v-if='vehicle.expirations.length > 0'>
            <div v-for='expiration in vehicle.expirations' :key='expiration.id' class='single-expiration'>
                <div>
                  <b>{{ expiration.name + ': ' }}</b> {{ standardDate(expiration.date) }}
                </div>
                <b-icon icon='pencil-square' class='app-icon edit-icon' @click='() => editExpiration(expiration)'></b-icon>
            </div>
          </div>
          <div v-else>
            No Expirations added
          </div>
        </div>
      </template>

      <template v-slot:collapsed>
        <app-collapsable-action-bar>
          <template v-slot:content>
          <app-action-bar-item
              name='Delete'
              icon='x-circle'
              v-if='hasPermission("vehicles", "update")'
              :onClick='deleteVehicle'
            />

            <app-action-bar-item
              name='Add Expiration'
              icon='stopwatch'
              v-if='hasPermission("vehicles", "update")'
              :onClick='addExpiration'
            />

            <app-action-bar-item
              name='Edit'
              icon='pencil-square'
              v-if='hasPermission("vehicles", "update")'
              :onClick='editVehicle'
            />
          </template>
        </app-collapsable-action-bar>
      </template>
    </app-collapsable-list-item>
  </section>
</template>

<script>
import EventBus from '@/store/eventBus';
import { standardDate } from '@/utils/dateUtils';

export default {
  props: {
    vehicle: {
      type: Object,
      required: true
    }
  },
  methods: {
    standardDate: standardDate,
    addExpiration() {
      EventBus.$emit('ADD_VEHICLE_EXPIRATION', this.vehicle.id);
    },
    editExpiration(expiration_id) {
      EventBus.$emit('EDIT_VEHICLE_EXPIRATION', expiration_id)
    },
    editVehicle() {
      EventBus.$emit('EDIT_VEHICLE', this.vehicle)
    },
    deleteVehicle() {
      let confirmed = confirm("Are you sure you want to permanently delete this equipment?");

      if(!confirmed) { return }

      this.axiosDelete(`/vehicles/${this.vehicle.id}`).then((response) => {
        EventBus.$emit('VEHICLE_UPDATED')
      })
    }
  }
}
</script>

<style scoped>
  .vehicle {
    font-size: 12px
  }

  .single-expiration {
    display: flex;
    align-items: center;
    margin-top: 6px;
    margin-bottom: 6px;
  }

  .edit-icon {
    margin-left: 4px;
  }
</style>
