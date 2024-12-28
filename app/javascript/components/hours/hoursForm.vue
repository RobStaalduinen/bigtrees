<template>
  <b-form autocomplete='false'>
    <p>
      {{ workRecord.arborist }}
    </p>
    <b-form-group
      label="Start at"
      label-for="edit_start_at"
    >
      <b-form-timepicker 
        v-model="workRecord.start_at" 
        @input='updateHours' 
        locale="en" 
        name='start_at' 
        offset='200' 
        minutes-step='10'
      >
      </b-form-timepicker>
    </b-form-group>

    <b-form-group
      label="End at"
      label-for="edit_end_at"
    >
      <b-form-timepicker 
        v-model="workRecord.end_at" 
        @input='updateHours' 
        locale="en" 
        name='end_at' 
        offset='200' 
        minutes-step='10'
      >
      </b-form-timepicker>
    </b-form-group>

    <b-form-group
      label="Unpaid hours"
      label-for="edit_unpaid"
    >
      <b-form-input type='number' v-model="workRecord.unpaid_hours" name='unpaid_hours' @input="updateHours"></b-form-input>
    </b-form-group>

    <b-form-group
      label="Total hours"
      label-for="edit_total"
    >
      <b-form-input type='number' v-model="workRecord.hours" name='hours' disabled></b-form-input>
    </b-form-group>

    <div id='submit-block'>
      <b-button block class='submit-button' @click.prevent='submitRecord'>Submit</b-button>
    </div>

  </b-form>
</template>

<script>
import axios from 'axios'
import moment from 'moment'

export default {
  props: {
    'workRecord': {
      type: Object,
      required: false
    },
    employee_id: {
      required: false
    }
  },
  methods:{
    submitRecord() {
      var options = {
        work_record: {
          start_at: this.workRecord.start_at,
          end_at: this.workRecord.end_at,
          unpaid_hours: this.workRecord.unpaid_hours,
          hours: this.workRecord.hours
        }
      }
      if(this.employee_id != null) {
        options.arborist_id = this.employee_id;
      }
      this.axiosPut(`/work_records/${this.workRecord.id}`, options)
        .then(response => {
          this.hours = response.data;
          this.$emit('hoursSubmitted');
          })
    },
    updateHours() {
      var start = moment(this.workRecord.start_at, 'HH:mm:ss');
      var end = moment(this.workRecord.end_at, 'HH:mm:ss');
      var duration = moment.duration(end.diff(start)).asHours();
      duration = Math.round(duration * 100) / 100;
      if(this.workRecord.unpaid_hours != null) {
        duration -= this.workRecord.unpaid_hours;
      }
      if(duration != NaN){
        this.workRecord.hours = duration;
      }
    }
  }
}
</script>

<style scoped>
  #submit-block {
    margin-top: 16px;
  }
</style>
