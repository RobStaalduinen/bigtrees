<template>
  <page-template>
    <app-header title='Hours'>
      <template v-slot:header-right>
        <a href='/work_records/report' v-if='admin'>
          <b-icon icon='download'></b-icon> 
          Tracker
        </a>
        <a href='/work_records/new' v-else>
          Record Hours
        </a>
      </template>
    </app-header>

    <div id='hours-body'>
      <div id='hours-container' v-if='admin'>
        <hours-table></hours-table>
      </div>

      <div id='summaries-container'>
        <summaries></summaries>
      </div>
    </div>
  </page-template>
</template>

<script>
import HoursTable from '../components/hours/hoursTable.vue';
import Summaries from '../components/hours/summaries.vue';

export default {
  components: {
    'hours-table': HoursTable,
    'summaries': Summaries
  },
  data() {
    return {

    }
  },
  computed: {
    admin() {
      return this.$store.state.user.admin;
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
