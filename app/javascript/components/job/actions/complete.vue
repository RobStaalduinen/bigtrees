<template>
  <app-right-sidebar :id='id' title='Finish Job' submitText='Submit' :onSubmit='completeJob' @shown='handleShown'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <h6>Job Completed At</h6>
        <app-datepicker
          v-model='completedDate'
          id='work-completed-date'
          name='work-completed-date'
          label='Date'
          validationRules='required'
          />
        <app-timepicker
          v-model='completedTime'
          id='work-completed-time'
          name='work-completed-time'
          label='Time'
          validationRules='required'
          />
      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import moment from 'moment';
import EventBus from '@/store/eventBus';


export default {
  props: {
    id: {
      required: true
    },
    estimate: {
      required: true
    }
  },
  data() {
    return {
      completedDate: moment().format('YYYY-MM-DD'),
      completedTime: moment().format('HH:mm'),
      organization: this.$store.state.organization,
    }
  },
  methods: {
    completeJob() {
      this.surveyError = false;

      let params = {
        job: {
          completed_at: `${this.completedDate} ${this.completedTime}`,
        }
      }

      this.axiosPost(`/estimates/${this.estimate.id}/jobs`, params)
        .then(response => {
          EventBus.$emit('ESTIMATE_UPDATED', response.data);
          this.$root.$emit('bv::toggle::collapse', this.id);
        })
    },
    handleShown() {
      this.completedDate = moment().format('YYYY-MM-DD');
      this.completedTime = moment().format('HH:mm');
    },
    skipStart() {


    }
  },
}
</script>

<style scoped>
  #survey-label {
    font-size: 0.9em
  }

  .survey-subtext {
    font-size: 0.9em;
    color: #6c757d;
  }
</style>