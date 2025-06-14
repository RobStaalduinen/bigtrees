<template>
  <app-right-sidebar :id='id' title='Update Completion Notes' submitText='Submit' :onSubmit='updateNotes' @cancelled='reset'>
    <template v-slot:content>
        <app-text-area
          v-model="notes"
          name="completion-notes"
          label='Completion Notes'
          :noResize='true'
          :rows=4
        />
    </template>
  </app-right-sidebar>
</template>

<script>
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
      notes: this.estimate.job.completion_notes || '',
    }
  },
  methods: {
    updateNotes() {
      let params = { job: { completion_notes: this.notes } };

      this.axiosPut(`/estimates/${this.estimate.id}/jobs`, params)
        .then(response => {
          EventBus.$emit('ESTIMATE_UPDATED', response.data);
          this.$root.$emit('bv::toggle::collapse', this.id);
        })
    },
    reset() {
      this.notes = this.estimate.job.completion_notes || '';
    }
  }
}
</script>

