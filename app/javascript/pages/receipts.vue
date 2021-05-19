<template>
  <page-template>
    <app-header title='Receipts'>
      <template v-slot:header-right>
        <a v-b-toggle.create-equipment-request v-if='hasPermission("receipts", "create")'>
          New
        </a>
      </template>
    </app-header>

    <app-create-equipment-request
      id='create-equipment-request'
      v-if='hasPermission("equipment_requests", "create")'
    ></app-create-equipment-request>
  </page-template>
</template>

<script>
import CreateEquipmentRequest from '@/components/equipment/actions/create'
import EventBus from '@/store/eventBus';
import SendToTeam from '@/components/equipment/actions/sendToTeam';

export default {
  components: {
    'app-create-equipment-request': CreateEquipmentRequest,
  },
  data() {
    return {
      selectedRequest: null
    }
  },
  mounted() {
    // EventBus.$on('RESOLVE_EQUIPMENT_REQUEST', (request) => {
    //   this.selectedRequest = request;
    //   this.$root.$emit('bv::toggle::collapse', 'resolve-equipment-request');
    // })

    // EventBus.$on('SEND_EQUIPMENT_REQUEST', (request) => {
    //   this.selectedRequest = request;
    //   this.$root.$emit('bv::toggle::collapse', 'send-equipment-request');
    // })
  }
}
</script>

<style scoped>

</style>
