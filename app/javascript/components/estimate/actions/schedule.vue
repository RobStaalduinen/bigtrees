<template>
  <app-right-sidebar :id='id' title='Schedule Work' submitText='Save' :onSubmit='updateWorkDate'>
    <template v-slot:content>
      <b-form-datepicker
        v-model='work_date'
        :date-format-options="{ year: 'numeric', month: 'numeric', day: 'numeric' }"
        locale='en-CA'
      >
      </b-form-datepicker>
    </template>
  </app-right-sidebar>
</template>

<script>

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
      work_date: this.estimate.work_date
    }
  },
  methods: {
    updateWorkDate() {
      var params = { estimate: { work_date: this.work_date } }
      this.axiosPut(`/estimates/${this.estimate.id}`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        this.$emit('changed', { estimate: response.data.estimate });
      })
    }
  },
}
</script>

<style scoped>

</style>
