<template>
  <page-template>
    <app-header title='Hours'>
      <template v-slot:header-right>
        <a @click='downloadTracker' v-if='hasPermission("hours", "admin")'>
          <b-icon icon='download'></b-icon>
          Tracker
        </a>
        <a v-else v-b-toggle.update-hours>
          Record Hours
        </a>
      </template>
    </app-header>

    <div id='hours-body'>
      <div id='hours-container' v-if='hasPermission("hours", "admin")'>
        <hours-table></hours-table>
      </div>

      <div id='summaries-container'>
        <summaries></summaries>
      </div>
    </div>

    <app-update-hours id='update-hours'></app-update-hours>
  </page-template>
</template>

<script>
import HoursTable from '../components/hours/hoursTable.vue';
import Summaries from '../components/hours/summaries.vue';
import UpdateHours from '@/components/hours/actions/update';

export default {
  components: {
    'hours-table': HoursTable,
    'summaries': Summaries,
    'app-update-hours': UpdateHours
  },
  methods: {
    downloadTracker() {
      this.axiosDownload('/work_records/report', 'HoursTracker.xlsx')
    }
  }
}
</script>

<style scoped>
  #hours-body{
    display: flex;
    flex-direction: column;
  }
  #hours-container{
    width: 100%;
  }

  #summaries-container{
    width: 100%;
    margin-top: 16px;
  }

  @media (min-width: 760px){
    #hours-body{
      flex-direction: row;
      justify-content: space-between;
    }

  #hours-container{
    width: 45%;
  }

  #summaries-container{
    width: 45%;
    margin-top: 0px;

  }
  }
</style>
