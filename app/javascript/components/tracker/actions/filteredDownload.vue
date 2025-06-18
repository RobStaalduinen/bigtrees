<template>
  <div>
    <app-select-field
      :options="options"
      v-model="scope"
      label="Estimates to Include"
    />
    <app-button text="Download Tracker" :click="downloadTracker" v-if="!loading" />
    <b-spinner id='submit-button-loader' v-if="loading"></b-spinner>
  </div>
</template>

<script>
  export default { 
    data() {
      return {
        loading: false,
        scope: 'all',
      }
    },
    computed: {
      options() {
        return [
          { value: 'all', text: 'All' },
          { value: 'past_year', text: 'Past Year' },
        ];
      }
    },
    methods: {
      downloadTracker() {
      this.loading = true;
      this.axiosDownload(`/trackers.xlsx?scope=${this.scope}`, 'MasterTracker.xlsx')
        .then(() => {
          this.loading = false;
          this.$bvModal.hide('tracker-download');
        })
        .catch(() => {
          this.loading = false;
          this.$bvModal.hide('tracker-download');
        });
      }
    },
  }
</script>

<style>

</style>