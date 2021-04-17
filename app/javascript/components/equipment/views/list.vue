<template>
<div class='request-list'>
  <app-select-field
    label='Status'
    v-model='status'
    name='status'
    :options="options"
  />
  <div
    class='single-request-container'
    v-for='request in equipmentRequests'
    :key='request.id'
  >
    <app-single-list-item :equipmentRequest='request'></app-single-list-item>
  </div>

</div>
</template>

<script>
import ListItem from './singleListItem';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-single-list-item': ListItem
  },
  data() {
    return {
      equipmentRequests: [],
      status: 'submitted',
      options: [
        { text: 'Submitted', value: 'submitted' },
        { text: 'Resolved', value: 'resolved' }]
    }
  },
  methods: {
    retrieveEquipmentRequests() {
      this.axiosGet(`/equipment_requests?state=${this.status}`).then(response => {
        this.equipmentRequests = response.data.equipment_requests
      })
    }
  },
  mounted() {
    this.retrieveEquipmentRequests();

    EventBus.$on('EQUIPMENT_REQUEST_UPDATED', () => {
      this.retrieveEquipmentRequests();
    })
  },
  watch: {
    status() {
      this.retrieveEquipmentRequests();
    }
  }
}
</script>

<style scoped>
  .single-request-container {
    margin-top: 8px;
  }
</style>
