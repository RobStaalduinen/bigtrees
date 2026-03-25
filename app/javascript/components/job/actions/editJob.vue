<template>
  <app-right-sidebar :id='id' title='Edit Visit' submitText='Save' :onSubmit='saveJob' @shown='handleShown'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <h6>Job Started At</h6>
        <app-datepicker
          v-model='startDate'
          id='edit-start-date'
          name='edit-start-date'
          label='Date'
          validationRules='required'
        />
        <app-timepicker
          v-model='startTime'
          id='edit-start-time'
          name='edit-start-time'
          label='Time'
          validationRules='required'
        />

        <hr/>

        <h6>Entrance Survey</h6>
        <div v-for='(question, index) in organization.job_survey_questions' :key='`entrance-${index}`'>
          <app-checkbox-highlight
            :id='`edit-entrance-${index}`'
            :label='question'
            v-model='entranceSurvey[question]'
            :checkedValue='true'
            label_id='survey-label'
          />
        </div>

        <hr/>

        <h6>Attendance</h6>
        <span class='survey-subtext'>Who is present on site?</span>
        <div v-for='(arborist, index) in assignableArborists' :key='`arborist-${arborist.id}`'>
          <app-checkbox-highlight
            :id='`edit-arborist-${arborist.id}`'
            :label='arborist.name'
            :checkedValue='arborist.id'
            label_id='survey-label'
            :value='arboristAssignments[arborist.id] ? arborist.id : null'
            @input='(payload) => arboristAssignments[arborist.id] = !!payload'
          />
        </div>

        <hr/>

        <h6>Job Completed At <span class='optional-label'>(optional)</span></h6>
        <app-datepicker
          v-model='completedDate'
          id='edit-completed-date'
          name='edit-completed-date'
          label='Date'
        />
        <app-timepicker
          v-model='completedTime'
          id='edit-completed-time'
          name='edit-completed-time'
          label='Time'
        />

        <hr/>

        <h6>Exit Survey</h6>
        <div v-for='(question, index) in organization.completion_survey_questions' :key='`exit-${index}`'>
          <app-checkbox-highlight
            :id='`edit-exit-${index}`'
            :label='question'
            v-model='exitSurvey[question]'
            :checkedValue='true'
            label_id='survey-label'
          />
        </div>

        <app-text-area
          v-model="notes"
          name="edit-completion-notes"
          label='Notes for Homeowner'
          :noResize='true'
          :rows=4
        />

        <app-select-field
          label='When will this site need a revisit?'
          v-model='revisit'
          name='edit-revisit'
          :options="revisitOptions"
        />

        <template v-if="showJobCompleteCheckbox">
          <hr/>
          <h6>Status</h6>
          <p class="status-subheading">Is the quoted job finished? Or will more visits be required to handle stumps, log pickup, further trimming etc.</p>
          <div class="status-radio-group">
            <label class="status-radio-option" :class="{ active: allTasksComplete }">
              <input type="radio" :value="true" v-model="allTasksComplete" />
              All quoted work complete
            </label>
            <label class="status-radio-option" :class="{ active: !allTasksComplete }">
              <input type="radio" :value="false" v-model="allTasksComplete" />
              More work required
            </label>
          </div>
        </template>

      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import moment from 'moment';
import EventBus from '@/store/eventBus';

export default {
  props: {
    id: { required: true },
    estimate: { required: true },
    job: { required: true }
  },
  data() {
    return this.initialData();
  },
  computed: {
    organization() {
      return this.$store.state.organization;
    },
    revisitOptions() {
      return [
        'Never',
        moment().format('YYYY'),
        moment().add(1, 'year').format('YYYY'),
        moment().add(2, 'years').format('YYYY'),
        moment().add(3, 'years').format('YYYY'),
        moment().add(4, 'years').format('YYYY'),
      ];
    },
    showJobCompleteCheckbox() {
      const jobs = this.estimate.jobs;
      const isLastJob = jobs[jobs.length - 1]?.id === this.job.id;
      return isLastJob && this.estimate.status !== 'work_completed';
    }
  },
  methods: {
    initialData() {
      const org = this.$store.state.organization;
      const job = this.job;

      const entranceSurvey = org.job_survey_questions.reduce((acc, q) => {
        acc[q] = job.job_survey_responses?.[q] ?? false;
        return acc;
      }, {});

      const exitSurvey = org.completion_survey_questions.reduce((acc, q) => {
        acc[q] = job.completion_survey_responses?.[q] ?? false;
        return acc;
      }, {});

      return {
        startDate: job.started_at ? moment.utc(job.started_at).format('YYYY-MM-DD') : moment().format('YYYY-MM-DD'),
        startTime: job.started_at ? moment.utc(job.started_at).format('HH:mm') : moment().format('HH:mm'),
        completedDate: job.completed_at ? moment.utc(job.completed_at).format('YYYY-MM-DD') : '',
        completedTime: job.completed_at ? moment.utc(job.completed_at).format('HH:mm') : '',
        entranceSurvey,
        exitSurvey,
        notes: job.completion_notes || '',
        revisit: job.followup_year ? String(job.followup_year) : 'Never',
        assignableArborists: [],
        arboristAssignments: {},
        allTasksComplete: false,
      };
    },
    handleShown() {
      // Re-sync from prop in case of updates
      const fresh = this.initialData();
      Object.assign(this.$data, fresh);
      this.retrieveArborists();
    },
    retrieveArborists() {
      this.axiosGet('/arborists?crew_member=true').then(response => {
        this.assignableArborists = response.data.arborists;
        // Pre-check assigned arborists
        const assignedIds = this.job.assigned_arborist_ids || [];
        const assignments = {};
        this.assignableArborists.forEach(a => {
          assignments[a.id] = assignedIds.includes(a.id);
        });
        this.arboristAssignments = assignments;
      });
    },
    saveJob() {
      const assignedIds = Object.keys(this.arboristAssignments)
        .filter(id => this.arboristAssignments[id])
        .map(Number);

      const params = {
        job: {
          started_at: `${this.startDate} ${this.startTime}`,
          job_survey_responses: this.entranceSurvey,
          completion_survey_responses: this.exitSurvey,
          completion_notes: this.notes,
          assigned_arborists: assignedIds,
        }
      };

      if (this.completedDate && this.completedTime) {
        params.job.completed_at = `${this.completedDate} ${this.completedTime}`;
      }

      if (this.revisit !== 'Never') {
        params.job.followup_year = this.revisit;
      } else {
        params.job.followup_year = null;
      }

      if (this.allTasksComplete) {
        params.work_complete = true;
      }

      this.axiosPut(`/estimates/${this.estimate.id}/jobs/${this.job.id}`, params)
        .then(response => {
          EventBus.$emit('ESTIMATE_UPDATED', response.data);
          this.$root.$emit('bv::toggle::collapse', this.id);
        });
    }
  }
}
</script>

<style scoped>
#survey-label {
  font-size: 0.9em;
}
.survey-subtext {
  font-size: 0.9em;
  color: #6c757d;
}
.optional-label {
  font-size: 0.8em;
  font-weight: normal;
  color: #6c757d;
}

.status-subheading {
  font-size: 0.75em;
  color: #6c757d;
  margin-bottom: 10px;
}

.status-radio-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 4px;
}

.status-radio-option {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9em;
  font-weight: normal;
  margin-bottom: 0;
  transition: border-color 0.15s, background-color 0.15s;
}

.status-radio-option:hover {
  border-color: #adb5bd;
  background-color: #f8f9fa;
}

.status-radio-option.active {
  border-color: var(--main-color);
  background-color: rgba(138, 0, 0, 0.07);
  color: var(--main-color);
  font-weight: 500;
}

.status-radio-option input[type="radio"] {
  margin: 0;
  flex-shrink: 0;
  accent-color: var(--main-color);
}
</style>
