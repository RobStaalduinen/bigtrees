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

          <hr/>

          <h6>Exit Survey</h6>

          <div v-for='(question, index) in organization.completion_survey_questions' :key='index'>
            <app-checkbox-highlight
                :id='`survey-checkbox-${index}`'
                :label='question'
                v-model='surveyAnswers[question]'
                :checkedValue='true'
                label_id='survey-label'
              />
          </div>

          <app-text-area
            v-model="notes"
            name="template-content"
            label='Notes for Homeowner'
            :noResize='true'
            :rows=4
          />

          <app-select-field
            label='When will this site need a revisit?'
            v-model='revisit'
            name='revisit'
            :options="revisitOptions"
            validationRules='required'
          />

          <hr/>

          <h6>Followup Actions</h6>
          <i style="font-size: 10px;">Please add tags for needed followup tasks.</i>

          <app-manage-tags
            :id="id"
            :estimate="estimate"
          />

      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import moment from 'moment';
import EventBus from '@/store/eventBus';
import ManageTags from '@/components/tags/views/manageEstimate.vue';


export default {
  components: {
    'app-manage-tags': ManageTags
  },
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
      surveyAnswers: this.$store.state.organization.completion_survey_questions.reduce((acc, question) => {
        acc[question] = false;
        return acc;
      }, {}),
      notes: '',
      revisit: 'Never',
    }
  },
  computed: {
    revisitOptions() {
      return [
        'Never',
        moment().format('YYYY'),
        moment().add(1, 'year').format('YYYY'),
        moment().add(2, 'years').format('YYYY'),
        moment().add(3, 'years').format('YYYY'),
        moment().add(4, 'years').format('YYYY'),
      ]
    },
  },
  methods: {
    completeJob() {
      this.surveyError = false;

      let params = {
        job: {
          completed_at: `${this.completedDate} ${this.completedTime}`,
          completion_survey_responses: this.surveyAnswers,
          completion_notes: this.notes,
        }
      }

      if (this.revisit !== 'Never') {
        params.job.followup_year = this.revisit;
      } else {
        params.job.followup_year = null;
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