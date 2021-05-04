<template>
  <page-template>
    <app-header title='Quotes'>
      <template v-slot:header-right>
        <a href='/trackers.xlsx' v-if='hasPermission("estimates", "admin")'>
          <b-icon icon='download'></b-icon>
          Tracker
        </a>
      </template>

    </app-header>

    <app-estimate-list></app-estimate-list>
  </page-template>
</template>

<script>
import EstimateList from '../components/estimates/list';
import { store } from '@/store/store'

export default {
  components: {
    'app-estimate-list': EstimateList
  },
  data() {
    return {

    }
  }
}
</script>

<style scoped>

</style>
