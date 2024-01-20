<template>
  <page-template>
    <app-header title='Equipment Requests'>
      <template v-slot:header-right>
        <div class='header-container'>
          <template v-if='hasPermission("equipment_requests", "admin")'>
            <a @click='downloadTracker'>
              <b-icon icon='download'></b-icon>
              Tracker
            </a>
            |
          </template>
          <a @click='toggleCreate' v-if='hasPermission("equipment_requests", "create")'>
            New
          </a>
        </div>
      </template>

    </app-header>

    <app-equipment-list></app-equipment-list>

    <app-create-equipment-request
      id='create-equipment-request'
      v-if='hasPermission("equipment_requests", "create")'
      :equipmentRequest='selectedRequest'
    ></app-create-equipment-request>

    <app-resolve-equipment-request
      id='resolve-equipment-request'
      :equipmentRequest='selectedRequest'
      v-if='hasPermission("equipment_requests", "update")'
    ></app-resolve-equipment-request>

    <app-send-equipment-request
      id='send-equipment-request'
      :equipmentRequest='selectedRequest'
      v-if='hasPermission("equipment_requests", "update")'
    />

    <app-assign-equipment-request
      id='assign-equipment-request'
      :equipmentRequest='selectedRequest'
      v-if='hasPermission("equipment_requests", "update")'
    />
  </page-template>
</template>

<script>
import EquipmentList from '@/components/equipment/views/list';
import CreateEquipmentRequest from '@/components/equipment/actions/create'
import EventBus from '@/store/eventBus';
import ResolveRequest from '@/components/equipment/actions/resolve';
import SendToTeam from '@/components/equipment/actions/sendToTeam';
import Assign from '@/components/equipment/actions/assign';

export default {
  components: {
    'app-resolve-equipment-request': ResolveRequest,
    'app-equipment-list': EquipmentList,
    'app-create-equipment-request': CreateEquipmentRequest,
    'app-send-equipment-request': SendToTeam,
    'app-assign-equipment-request': Assign
  },
  data() {
    return {
      selectedRequest: null
    }
  },
  mounted() {
    EventBus.$on('RESOLVE_EQUIPMENT_REQUEST', (request) => {
      this.selectedRequest = request;
      this.$root.$emit('bv::toggle::collapse', 'resolve-equipment-request');
    })

    EventBus.$on('SEND_EQUIPMENT_REQUEST', (request) => {
      this.selectedRequest = request;
      this.$root.$emit('bv::toggle::collapse', 'send-equipment-request');
    })

    EventBus.$on('ASSIGN_EQUIPMENT_REQUEST', (request) => {
      this.selectedRequest = request;
      this.$root.$emit('bv::toggle::collapse', 'assign-equipment-request');
    })

    EventBus.$on('EDIT_EQUIPMENT_REQUEST', (request) => {
      this.selectedRequest = request;
      this.$root.$emit('bv::toggle::collapse', 'create-equipment-request');
    })
  },
  methods: {
    toggleCreate() {
      this.selectedRequest = null;
      this.$root.$emit('bv::toggle::collapse', 'create-equipment-request');
    },
    downloadTracker() {
      this.axiosDownload('/equipment_requests/tracker.xlsx', 'RepairRequestTracker.xlsx')
    }
  }
}
</script>

<style scoped>

</style>
