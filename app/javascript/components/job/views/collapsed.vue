<template>
  <div>
    <app-collapsable id='job-collapse'>
      <template v-slot:title>
        <b>Job</b> &nbsp; - {{ jobStatus() }}
      </template>

      <template v-slot:content>
        <div v-if="estimate.jobs.length === 0">
          <p>No visits recorded.</p>
        </div>

        <div v-for="(job, index) in estimate.jobs" :key="job.id" class="visit-card">

          <div class="visit-header">
            <span class="visit-title">Visit #{{ index + 1 }}</span>
            <span class="visit-lead">{{ job.lead_arborist_name }}</span>
          </div>

          <div class="visit-body">
            <div class="visit-timeline">
              <span>{{ formatVisitTime(job.started_at) }}</span>
              <span v-if="job.completed_at" class="timeline-separator">→</span>
              <span v-if="job.completed_at">{{ formatVisitTime(job.completed_at) }}</span>
              <span v-if="job.completed_at" class="timeline-duration">({{ hoursWorked(job) }} hrs)</span>
              <span v-else class="timeline-active">In progress</span>
            </div>

            <div v-if="job.assigned_arborist_names.length > 0" class="visit-section">
              <div class="section-label">Crew on site</div>
              <div class="section-content">{{ job.assigned_arborist_names.join(', ') }}</div>
            </div>

            <div class="visit-section">
              <div class="section-label">Entrance Survey</div>
              <div class="section-content survey-responses">
                <span v-for='(value, question, i) in job.job_survey_responses' :key='i'>
                  {{ question }}: <span :style="{ color: value ? 'green' : 'red', fontWeight: 'bold' }">{{ value ? 'YES' : 'NO' }}</span><br>
                </span>
              </div>
            </div>

            <template v-if="job.completed_at">
              <div class="visit-section">
                <div class="section-label">Exit Survey</div>
                <div class="section-content survey-responses">
                  <span v-for='(value, question, i) in job.completion_survey_responses' :key='i'>
                    {{ question }}: <span :style="{ color: value ? 'green' : 'red', fontWeight: 'bold' }">{{ value ? 'YES' : 'NO' }}</span><br>
                  </span>
                </div>
              </div>

              <div class="visit-section">
                <div class="section-label">
                  Arborist Notes
                  <b-icon v-if="index === estimate.jobs.length - 1" icon='pencil-square' class='app-icon edit-icon' @click="toggleUpdate()"></b-icon>
                </div>
                <div class="section-content">{{ job.completion_notes || '—' }}</div>
              </div>

              <div class="visit-section">
                <div class="section-label">Followup Year</div>
                <div class="section-content">{{ job.followup_year || 'Never' }}</div>
              </div>
            </template>
          </div>

        </div>
      </template>
    </app-collapsable>
    <app-update-notes :estimate='estimate' id='update-notes'></app-update-notes>
  </div>
</template>

<script>
import moment from 'moment';
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
      const jobs = this.estimate.jobs;

      if (!jobs || jobs.length === 0) {
        return 'Not Started';
      }

      const activeJob = jobs.find(j => j.started_at && !j.completed_at);
      if (activeJob) {
        return 'In Progress';
      }

      if (this.estimate.work_complete) {
        return 'Completed';
      }

      return 'Paused';
    },
    formatVisitTime(date) {
      return moment(date).format('MMM Do, YYYY h:mm a');
    },
    hoursWorked(job) {
      const duration = moment(job.completed_at).diff(moment(job.started_at), 'minutes');
      return (duration / 60).toFixed(2);
    },
    toggleUpdate() {
      this.$root.$emit('bv::toggle::collapse', 'update-notes');
    }
  }
}
</script>

<style scoped>
.visit-card {
  font-size: 0.88em;
  background-color: #f4f4f4;
  border-radius: 6px;
  overflow: hidden;
  margin-bottom: 0.75rem;
}

.visit-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  background-color: #e0e0e0;
  padding: 0.45rem 1rem;
}

.visit-title {
  font-weight: bold;
  font-size: 1.05em;
}

.visit-lead {
  color: #555;
  font-style: italic;
}

.visit-body {
  padding: 0.5rem 1rem 0.75rem;
}

.visit-timeline {
  font-size: 0.82em;
  color: #444;
  margin-bottom: 0.5rem;
  display: flex;
  flex-wrap: wrap;
  gap: 0.3rem;
  align-items: center;
}

.timeline-separator {
  color: #999;
}

.timeline-duration {
  color: #666;
  font-style: italic;
}

.timeline-active {
  color: #2a7d2a;
  font-style: italic;
}

.visit-section {
  margin-top: 0.5rem;
}

.section-label {
  font-weight: 800;
  color: #444;
  font-size: 0.8em;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  margin-bottom: 0.15rem;
}

.section-content {
  color: #222;
}

.survey-responses {
  line-height: 1.6;
}
</style>
