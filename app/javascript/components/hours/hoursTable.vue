<template>
  <div>
    <app-shadow-box>
      <template v-slot:box-header>
        <h5>Daily Records</h5>

        <div id ='record-controls'>
          <div class='record-control-row'>
            <div id='record-start'>
              <b-form-datepicker 
                size='sm' v-model='start_at' 
                :date-format-options="{ year: 'numeric', month: 'numeric', day: 'numeric' }"
                @input='retrieveHours'
                locale='en-CA'
              >
              </b-form-datepicker>
            </div>

            <span> - </span>

            <div id='record-start'>
              <b-form-datepicker size='sm' 
                v-model='end_at' 
                :date-format-options="{ year: 'numeric', month: 'numeric', day: 'numeric' }"
                offset="-125"
                @input='retrieveHours'
                locale='en-CA'
              >
              </b-form-datepicker>
            </div>
          </div>
        </div>
      </template>

      <template v-slot:box-body>
        <section v-if='hours != null'>
          <div v-for='(records, date, index) in hours' :key='date'>

            <table class='record-table'>
              <tr class='record-row header-row'>
                <th class='row-entry-lg'>{{ date }}</th>
                <template>
                  <th class='row-entry'>{{ index == 0 ? 'Start' : '' }}</th>
                  <th class='row-entry'>{{ index == 0 ? 'End' : '' }}</th>
                  <th class='row-entry-sm'>{{ index == 0 ? 'Unpaid' : '' }}</th>
                  <th class='row-entry-sm'>{{ index == 0 ? 'Hours' : '' }}</th>
                  <th class='row-entry-sm'></th>
                </template>
              </tr>

              <editable-row v-for='record in records' :work-record='record' :key='record.id' @editToggled='openEdit($event)'></editable-row>

            </table>
          </div>
        </section>

        <app-loader v-if="loadingHours"></app-loader>

        <template v-if="!loadingHours">
          <section v-if="hours == null || Object.keys(hours).length === 0" id='no-hours'>
            No hours for timeframe.
          </section>
        </template>

      </template>
    </app-shadow-box>
  
    <b-modal id="editModal" centered title='Edit Record'>
      <div v-if="editSelectedRecord != null">
        <hours-form :work-record='editSelectedRecord' @hoursSubmitted='closeEdit'></hours-form>
      </div>
      <template v-slot:modal-footer><p></p></template>
    </b-modal>

  </div>
</template>

<script>
import axios from 'axios'
import EditableRow from './editableRow';
import HoursForm from './hoursForm';
import moment from 'moment';

export default {
  components: {
    'editable-row': EditableRow,
    'hours-form': HoursForm
  },
  data() {
    return {
      hours: null,
      start_at: moment().add(-7, 'days').format('YYYY-MM-DD'),
      end_at: moment().format('YYYY-MM-DD'),
      editSelectedRecord: null,
      loadingHours: true
    }
  },
  mounted() {
    this.retrieveHours();
  },
  methods: {
    retrieveHours() {
      this.loadingHours = true;
      this.axiosGet(`/work_records.json?start_at=${this.start_at}&end_at=${this.end_at}`)
          .then(response => {
            this.hours = response.data;
            this.loadingHours = false;
          })
    },
    openEdit(record) {
      this.editSelectedRecord = record;
      this.$bvModal.show('editModal');
    },
    closeEdit(){
      this.$bvModal.hide('editModal');
    }
  },
}
</script>

<style scoped>
  .record-table{
    width: 100%;
  }

  .header-row{
    background-color: #f7f7f7;
  }

  .record-row {
    font-size: 12px;

    border-width: 0 0 1px 0;
    border-color: lightgray;
    border-style: solid;
  }

  .record-row > th {
    padding-left: 4px;
  }

  .row-entry-lg{
    width: 20%;
  }

  .row-entry{
    width: 15%;
  }

  .row-entry-sm{
    width: 8%;
  }

  #no-hours {
    padding: 8px;
  }

  .record-control-row{
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 16px;
  }

  #record-start{
    width: 45%;
  }
</style>
