<template>
  <div>
    <app-collapsable id='job-collapse'>
      <template v-slot:title>
        <b>Job</b> &nbsp; - {{ jobStatus() }}
      </template>

      <template v-slot:content v-if="!estimate.job.skipped">
        <div class='collapsed-row'>
          <div class='collapsed-row-label'>
            <b>Started At</b>
          </div>

          <div class='collapsed-row-value'>
            {{ estimate.job.started_at | localizeDateTime }}
          </div>
        </div>
        <div class='collapsed-row' v-if="estimate.job.completed_at">
          <div class='collapsed-row-label'>
            <b>Completed At</b>
          </div>

          <div class='collapsed-row-value'>
            {{ estimate.job.completed_at | localizeDateTime }}
          </div>
        </div>

        <div class='collapsed-row'>
          <div class='collapsed-row-label'>
            <b>Crew on site</b>
          </div>

          <div class='collapsed-row-value'>
            {{ estimate.job.assigned_arborist_names.join(', ') }}
          </div>
        </div>

        <div class='collapsed-row'>
          <div class='collapsed-row-label'>
            <b>Entrance Survey</b>
          </div>

          <div class='collapsed-row-value entrance-survey'>
            <span v-for='(value, question, index) in estimate.job.job_survey_responses' :key='index'>
              {{ question }}: <span class='survey-answer-label' :style="{ color: value ? 'green' : 'red' }">{{ value ? 'YES' : 'NO' }}</span><br>
            </span>
    
          </div>
        </div>

        <div class='collapsed-row' v-if="estimate.job.completed_at">
          <div class='collapsed-row-label'>
            <b>Exit Survey</b>
          </div>

          <div class='collapsed-row-value entrance-survey'>
            <span v-for='(value, question, index) in estimate.job.completion_survey_responses' :key='index'>
              {{ question }}: <span class='survey-answer-label' :style="{ color: value ? 'green' : 'red' }">{{ value ? 'YES' : 'NO' }}</span><br>
            </span>
          </div>
        </div>

        <div class='collapsed-row' v-if="estimate.job.completed_at">
          <div class='collapsed-row-label'>
            <b>Arborist Notes</b>
            <b-icon icon='pencil-square' class='app-icon edit-icon' @click="toggleUpdate()"></b-icon>
          </div>

          <div class='collapsed-row-value'>
            {{ estimate.job.completion_notes }}
          </div>
        </div>


        <div class='collapsed-row' v-if="estimate.job.completed_at">
          <div class='collapsed-row-label'>
            <b>Followup Year</b>
          </div>

          <div class='collapsed-row-value'>
            {{ estimate.job.followup_year || 'Never' }} 
          </div>
        </div>

        <div class='collapsed-row'>
          <div class='collapsed-row-label'>
            <b>Survey Filled by</b>
          </div>

          <div class='collapsed-row-value'>
            {{ estimate.job.lead_arborist_name }}
          </div>
        </div>
      </template>
    </app-collapsable>
    <app-update-notes :estimate='estimate' id='update-notes'></app-update-notes>
    <!-- <app-edit-costs :estimate='estimate' id='edit-costs'></app-edit-costs> -->
  </div>
</template>

<script>
import UpdateNotes from '@/components/job/actions/updateNotes.vue';

export default {
  components: {
    'app-update-notes': UpdateNotes
  },
  props: {
    estimate: {
      required: true
    }
  },
  methods: {
    jobStatus() {
      let job = this.estimate.job;

      if(job.skipped) {
        return 'Submission skipped';
      }

      if(!job || !job.started_at) {
        return 'Not Started';
      }
      else if(!job.completed_at) {
        return 'Started';
      }
      else if(job.completed_at) {
        return 'Completed';
      }
    },
    toggleUpdate() {
      this.$root.$emit('bv::toggle::collapse', 'update-notes');
    }
  }
}
</script>

<style scoped>
.collapsed-row {
  display: flex;
  padding: 0.5rem 0;
}
.collapsed-row-label {
  font-weight: bold;
  width: 30%;
  text-align: right;
}
.collapsed-row-value {
  font-weight: normal;
  width: 70%;
  text-align: left;
  padding-left: 1rem;
}

.entrance-survey {
  font-size: 0.9em;
}

.survey-answer-label {
  font-weight: bold;
  color: green;
}
</style>