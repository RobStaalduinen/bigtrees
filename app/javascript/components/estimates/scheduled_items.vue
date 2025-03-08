<template>
  <div>
    <div class='scheduled-item-container'>
      <app-scheduled-item v-for='estimate in estimates' :key='estimate.id' :estimate='estimate'></app-scheduled-item>
    </div>
  </div>
</template>

<script>
  import ScheduledItem from './scheduled_item.vue';

  export default {
    components: {
      'app-scheduled-item': ScheduledItem
    },
    data() {
      return {
        estimates: []
      }
    },
    methods: {
      retrieveEstimates() {
        var params = {
          page: 1,
          per_page: 200,
          created_after: 'one_year',
          status: 'scheduled'
        }

        this.axiosGet(`/estimates.json`, params)
          .then(response => {
            this.estimates = response.data.estimates;
          })
      }
    },
    mounted() {
      this.retrieveEstimates();
    }
  }
</script>