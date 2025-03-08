<template>
  <app-right-sidebar-form
    :id='id'
    title='Approve'
    submitText='Approve'
    :onSubmit='approveEstimate'
    :submitting='submitting'
  >

    <template v-slot:content>
      <div>Customer has approved work?</div>
    </template>
  </app-right-sidebar-form>
</template>

<script>
import EventBus from '@/store/eventBus'


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
      submitting: false,
    }
  },
  methods: {
    approveEstimate() {
      this.submitting = true;
      var params = {
        estimate: {
          approved: true
        }
      }
      
      this.axiosPut(`/estimates/${this.estimate.id}`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
        this.submitting = false;
      })
    }
  }
}
</script>

<style scoped>
  .form-box {
    margin-bottom: 16px;
  }
</style>