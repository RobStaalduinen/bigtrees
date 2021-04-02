<template>
  <div>
    <b-form-group
      label="Date"
      label-for="work_record.date"
    >
      <b-form-datepicker
        v-model='date'
        :date-format-options="{ year: 'numeric', month: 'numeric', day: 'numeric' }"
        locale='en-CA'
        name='date'
      >
      </b-form-datepicker>
    </b-form-group>

    <b-form-group
      label="Start at"
      label-for="start_at"
    >
      <b-form-timepicker
        v-model="start_at"
        @input='updateHours'
        locale="en"
        name='start_at'
        minutes-step='15'
      >
      </b-form-timepicker>
    </b-form-group>

    <b-form-group
      label="End at"
      label-for="end_at"
    >
      <b-form-timepicker
        v-model="end_at"
        @input='updateHours'
        locale="en"
        name='end_at'
        minutes-step='15'
      >
      </b-form-timepicker>
    </b-form-group>

    <app-input-field
      v-model='unpaid_hours'
      name='unpaid_hours'
      label='Unpaid Hours'
      inputType='number'
      @input='updateHours'
    ></app-input-field>

    <app-input-field
      v-model='hours'
      name='hours'
      label='Total Hours'
      inputType='number'
      :disabled='true'
    ></app-input-field>
  </div>
</template>

<script>
import moment from 'moment';
export default {
  data() {
    return {
      date: moment().format('YYYY-MM-DD'),
      start_at: '08:00:00',
      end_at: '17:00:00',
      unpaid_hours: 0,
      hours: 0
    }
  },
  computed: {
    work_record() {
      return {
        date: this.date,
        start_at: this.start_at,
        end_at: this.end_at,
        unpaid_hours: this.unpaid_hours,
        hours: this.hours
      }
    }
  },
  methods: {
    updateHours() {
      var start = moment(this.start_at, 'HH:mm:ss');
      var end = moment(this.end_at, 'HH:mm:ss');
      var duration = moment.duration(end.diff(start)).asHours();
      duration = Math.round(duration * 100) / 100;
      if(this.unpaid_hours != null) {
        duration -= this.unpaid_hours;
      }
      if(duration != NaN){
        this.hours = duration;
      }
    }
  },
  watch: {
    work_record(){
      this.$emit('input', this.work_record);
    }
  },
  mounted() {
    this.updateHours();
  }
}
</script>

<style scoped>

</style>>
