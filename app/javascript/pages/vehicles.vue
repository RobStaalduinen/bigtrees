<template>
  <page-template>
    <app-header title='Vehicles and Equipment'>
      <template v-slot:header-right>
        <a v-b-toggle.create-vehicle v-if='hasPermission("vehicles", "create")'>
          New
        </a>
      </template>
    </app-header>

    <app-vehicle-list
      :vehicles='vehicles'
    ></app-vehicle-list>

    <app-create-vehicle
      id='create-vehicle'
      v-if='hasPermission("vehicles", "create")'
    ></app-create-vehicle>

      <app-add-vehicle-expiration
        id='add-vehicle-expiration'
        v-if='hasPermission("vehicles", "create")'
        :vehicle_id='selectedVehicle'
        :expiration='selectedExpiration'
      ></app-add-vehicle-expiration>
  </page-template>
</template>

<script>
import EventBus from '@/store/eventBus';
import List from '@/components/vehicles/views/list';
import CreateVehicle from '@/components/vehicles/actions/create';
import AddExpiration from '@/components/vehicles/actions/addExpiration';

export default {
  components: {
    'app-vehicle-list': List,
    'app-create-vehicle': CreateVehicle,
    'app-add-vehicle-expiration': AddExpiration
  },
  data() {
    return {
      vehicles: [],
      selectedVehicle: null,
      selectedExpiration: null
    }
  },
  methods: {
    retrieveVehicles() {
      this.axiosGet('/vehicles').then(response => {
        this.vehicles = response.data.vehicles;
      })
    },
    activateExpiration(id){
      this.selectedVehicle = id;
      this.selectedExpiration = null;
      this.$root.$emit('bv::toggle::collapse', 'add-vehicle-expiration');
    },
    editExpiration(expiration) {
      console.log(expiration);
      this.selectedVehicle = null;
      this.selectedExpiration = expiration;
      this.$root.$emit('bv::toggle::collapse', 'add-vehicle-expiration');
    }
  },
  mounted() {
    this.retrieveVehicles();

    EventBus.$on('VEHICLE_UPDATED', () => {
      this.retrieveVehicles();
    })

    EventBus.$on('ADD_VEHICLE_EXPIRATION', (id) => {
      this.activateExpiration(id);
    })

    EventBus.$on('EDIT_VEHICLE_EXPIRATION', (expiration) => {
      this.editExpiration(expiration);
    })
  }
}
</script>

<style scoped>

</style>
