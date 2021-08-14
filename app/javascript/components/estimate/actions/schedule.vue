<template>
  <app-right-sidebar :id='id' title='Schedule Work' submitText='Save' :onSubmit='updateWorkDate'>
    <template v-slot:content>
    <validation-observer ref="observer">
      <app-datepicker
        v-model='work_start_date'
        locale='en-CA'
        id='start-date'
        name='start-date'
        label='Start Date'
        validationRules='required'
      >
      </app-datepicker>

      <app-datepicker
        v-model='work_end_date'
        locale='en-CA'
        id='end-date'
        name='end-date'
        label='End Date'
        validationRules='required'
      >
      </app-datepicker>

    </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import EventBus from '@/store/eventBus'

export default {
  components: {
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
      work_start_date: this.estimate.work_start_date,
      work_end_date: this.estimate.work_end_date
    }
  },
  methods: {
    updateWorkDate() {
      var params = { estimate: { work_start_date: this.work_start_date, work_end_date: this.work_end_date } }

      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }
        this.axiosPut(`/estimates/${this.estimate.id}`, params).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('ESTIMATE_UPDATED', response.data);
        })
      })
    }
  },
}
</script>

<style scoped>

</style>
