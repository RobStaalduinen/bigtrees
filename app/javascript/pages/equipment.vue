<template>
  <page-template>
    <app-header title='Equipment Requests'></app-header>

    <app-equipment-list></app-equipment-list>
  </page-template>
</template>

<script>
import EquipmentList from '@/components/equipment/views/list';

export default {
  components: {
    'app-equipment-list': EquipmentList
  },
  data() {
    return {
    }
  },
}
</script>

<style scoped>

</style>
