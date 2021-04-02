<template>
  <app-right-sidebar :id='id' title='Submit Hours' submitText='Submit' :onSubmit='createHours'>
    <template v-slot:content>
      <app-work-record-form v-model='work_record'></app-work-record-form>
    </template>
  </app-right-sidebar>
</template>

<script>
import WorkRecordForm from '../forms/single';
import EventBus from '@/store/eventBus';

export default {
  props: ['id'],
  data() {
    return {
      work_record: {}
    }
  },
  components: {
    'app-work-record-form': WorkRecordForm
  },
  methods: {
    createHours() {
      let params = { work_record: this.work_record }

      this.axiosPost('/work_records', params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('WORK_RECORD_UPDATED');
      })
    }
  }
}
</script>

<style scoped>

</style>
