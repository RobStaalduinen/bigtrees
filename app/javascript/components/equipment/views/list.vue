<template>
<div class='request-list'>
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

export default {
  components: {
    'app-single-list-item': ListItem
  },
  data() {
    return {
      equipmentRequests: []
    }
  },
  methods: {
    retrieveEquipmentRequests() {
      this.axiosGet('/equipment_requests').then(response => {
        this.equipmentRequests = response.data.equipment_requests
      })
    }
  },
  mounted() {
    this.retrieveEquipmentRequests();
  }
}
</script>

<style scoped>
  .single-request-container {
    margin-top: 8px;
  }
</style>
