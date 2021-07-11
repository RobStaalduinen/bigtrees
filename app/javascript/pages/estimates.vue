<template>
  <page-template>
    <app-header title='Quotes'>
      <template v-slot:header-center>
        <div id='schedule-toggle'>
          <div>All</div>
          <toggle-button
            v-model='mySchedule'
            color='#8A0000'
            id='schedule-toggle-control'
          ></toggle-button>
          <div>My Schedule</div>
        </div>
      </template>

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
      mySchedule: false
    }
  },
  watch: {
    mySchedule() {
      store.commit('setEstimateSettings', { mySchedule: this.mySchedule });
    }
  }
}
</script>

<style scoped>
  #schedule-toggle {
    display: flex;
    align-items: center;

    font-size: 12px;
  }

  #schedule-toggle-control {
    margin-bottom: 0px;
    margin-left: 8px;
    margin-right: 8px;
  }
</style>
