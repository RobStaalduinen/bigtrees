<template>
  <div class='summary-container'>
    <table v-if="hours !=null" id='summary-table'>
      <template v-for="(hourRecord, index) in hours">
        <tr :key='index' class='hours-row date-row'>
          <th> {{ hourRecord.date }}</th>
          <th> {{ hourRecord.total }}</th>
        </tr>
        <tr v-for='(arboristRecord, arIndex) in hourRecord.hours' :key="'ar' + index + '_' + arIndex" class='hours-row'>
          <td>{{ arboristRecord.name }}</td>
          <td>{{ arboristRecord.hours }}</td>
        </tr>
      </template>

    </table>

    <app-loader v-if='loadingSummary'></app-loader>
  </div>
</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  props: ['summaryType'],
  data() {
    return {
      hours: null,
      loadingSummary: true
    }
  },
  methods: {
    retrieveSummary() {
      this.axiosGet(`/work_records/summaries?summary_type=${this.summaryType}`)
        .then(response => {
          console.log(response);
          if(response.status == 200){
            this.hours = response.data;
            this.loadingSummary = false;
          }
        })
    }
  },
  mounted(){
    this.retrieveSummary();

    EventBus.$on('WORK_RECORD_UPDATED', () => {
      this.retrieveSummary();
    });
  }
}
</script>

<style scoped>
  .summary-container{

  }

  #summary-table{
    width: 100%;
  }

  .hours-row{
    border-width: 0 0 1px 0;
    border-color: lightgrey;
    border-style: solid;


    font-size: 12px;
  }

  .hours-row > td {
    padding: 4px 8px
  }

    .hours-row > th {
    padding: 4px 8px
  }

  .date-row{
    background-color: #f8f7f7;
    font-size: 14px;
  }
</style>
