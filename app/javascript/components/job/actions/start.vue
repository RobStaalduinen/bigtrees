<template>
  <app-right-sidebar :id='id' title='Start Job' submitText='Start' :onSubmit='startJob' :alternateAction='skipJob' alternateActionText='Skip'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <h6>Job Started At</h6>
        <app-datepicker
          v-model='startDate'
          id='work-start-date'
          name='work-start-date'
          label='Date'
          validationRules='required'
          />
        <app-timepicker
          v-model='startTime'
          id='work-start-time'
          name='work-start-time'
          label='Time'
          validationRules='required'
          />

          <hr/>

          <h6>Entrance Survey</h6>

          <span class='survey-error' v-if='surveyError'>Check all entrance requirements before starting job.</span>

          <div v-for='(question, index) in organization.job_survey_questions' :key='index'>
            <app-checkbox-highlight
                :id='`survey-checkbox-${index}`'
                :label='question'
                v-model='surveyAnswers[question]'
                :checkedValue='true'
                label_id='survey-label'
              />
          </div>

          <hr/>

          <h6>Attendance</h6>
          <span class='survey-subtext'>Who is present on site?</span>

          <div v-if='assignableArborists.length > 0'>
            
            <div v-for='(arborist, index) in assignableArborists' :key='index'>
              <app-checkbox-highlight
                :id='`arborist-checkbox-${arborist.id}`'
                :label='arborist.name'
                :checkedValue='arborist.id'
                label_id='survey-label'
                @input='(payload) => arboristAssignments[arborist.id] = payload'
              />
            </div>
          </div>
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
      startDate: moment().format('YYYY-MM-DD'),
      startTime: moment().format('HH:mm'),
      organization: this.$store.state.organization,
      surveyAnswers: this.$store.state.organization.job_survey_questions.reduce((acc, question) => {
        acc[question] = false;
        return acc;
      }, {}),
      assignableArborists: [],
      arboristAssignments: {},
      surveyError: false
    }
  },
  methods: {
    startJob() {
      this.surveyError = false;
      let assignedIds = Object.keys(this.arboristAssignments).filter(key => this.arboristAssignments[key]);

      let params = {
        job: {
          started_at: `${this.startDate} ${this.startTime}`,
          job_survey_responses: this.surveyAnswers,
          assigned_arborists: assignedIds
        }
      }

      this.axiosPost(`/estimates/${this.estimate.id}/jobs`, params)
        .then(response => {
          EventBus.$emit('ESTIMATE_UPDATED', response.data);
          this.$root.$emit('bv::toggle::collapse', this.id);
        })
    },
    retrieveArborists() {
      this.axiosGet(`/arborists?crew_member=true`)
        .then(response => {
          this.assignableArborists = response.data.arborists;
        })
    },
    skipJob() {
      this.axiosPost(`/estimates/${this.estimate.id}/jobs`, { job: { skipped: true } })
        .then(response => {
          EventBus.$emit('ESTIMATE_UPDATED', response.data);
          this.$root.$emit('bv::toggle::collapse', this.id);
        })

    }
  },
  watch: {
    organization() {
      console.log('organization changed');
      console.log(this.organization);
    }
  },
  mounted() {
    this.retrieveArborists();
  }
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

  .survey-error {
    color: red;
    font-size: 0.8em;
    font-style: italic;
  }
</style>