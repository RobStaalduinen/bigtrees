<template>
  <page-template>
    <app-header title='Equipment Requests'>
      <template v-slot:header-right>
        <a v-b-toggle.create-equipment-request v-if='hasPermission("equipment_requests", "create")'>
          New
        </a>
      </template>

    </app-header>

    <app-equipment-list></app-equipment-list>

    <app-create-equipment-request
      id='create-equipment-request'
      v-if='hasPermission("equipment_requests", "create")'
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
  </page-template>
</template>

<script>
import EquipmentList from '@/components/equipment/views/list';
import CreateEquipmentRequest from '@/components/equipment/actions/create'
import EventBus from '@/store/eventBus';
import ResolveRequest from '@/components/equipment/actions/resolve';
import SendToTeam from '@/components/equipment/actions/sendToTeam';

export default {
  components: {
    'app-resolve-equipment-request': ResolveRequest,
    'app-equipment-list': EquipmentList,
    'app-create-equipment-request': CreateEquipmentRequest,
    'app-send-equipment-request': SendToTeam
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
  }
}
</script>

<style scoped>

</style>
