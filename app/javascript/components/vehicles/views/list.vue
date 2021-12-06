<template>
  <div>
    <div v-for='vehicle in vehicles' :key='vehicle.id' class='vehicle-wrapper'>
      <app-single-vehicle
        :vehicle='vehicle'
      />
    </div>
  </div>
</template>

<script>
import SingleListItem from './singleListItem';

export default {
  components: {
    'app-single-vehicle': SingleListItem
  },
  props: {
    vehicles: {
      type: Array,
      required: true
    }
  }
}
</script>

<style>
  .vehicle-wrapper {
    margin-bottom: 8px;
  }
</style>
