<template>
<div class='request-list'>
  <app-select-field
    label='Status'
    v-model='status'
    name='status'
    :options="listOptions"
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
      status: 'submitted'
    }
  },
  computed: {
    listOptions() {
      let options = [
        { text: 'Submitted', value: 'submitted' },
        { text: 'Assigned', value: 'assigned' },
        { text: 'Resolved', value: 'resolved' }
      ];

      if(this.userRole() == 'mechanic'){
        options.shift();
        this.status = 'assigned'
      }

      return options;
    }
  },
  methods: {
    retrieveEquipmentRequests() {
      this.axiosGet(`/equipment_requests?state=${this.status}`).then(response => {
        console.log(response.data);
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
