<template>
  <page-template>
    <app-header title='Schedule'></app-header> 
    <app-scheduled-items></app-scheduled-items>
  </page-template>
</template>

<script>
  import ScheduledItems from '../components/estimates/scheduled_items.vue';

  export default {
    components: {
      'app-scheduled-items': ScheduledItems
    }
  }
</script>

<style scoped>
</style>