<template>
  <page-template>
    <app-header :title='"Estimate #" + estimate_id' backLink='/admin/estimates'></app-header>

    <div v-if='estimate' id='estimate-body'>
      <single-estimate-owner :estimate='estimate' @changed='(payload) => handleUpdate(payload)'></single-estimate-owner>
    </div>
  </page-template>
</template>

<script>
import Owner from '../components/singleEstimate/owner';

export default {
  components: {
    'single-estimate-owner': Owner
  },
  data() {
    return {
      estimate_id: this.$route.params.estimate_id,
      estimate: null
    }
  },
  mounted() {
    this.retrieveEstimate();
  },
  methods: {
    retrieveEstimate() {
      this.axiosGet(`/estimates/${this.estimate_id}.json`)
        .then(response => {
          this.estimate = response.data.estimate;
        })
    },
    handleUpdate(payload) {
      this.estimate = Object.assign({}, this.estimate, payload);
    }
  }
}
</script>

<style scoped>
  #estimate-body {
    padding: 0 8px;
  }
</style>
