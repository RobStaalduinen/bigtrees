<template>
  <page-template>
    <app-header :title='"Estimate #" + estimate_id' backLink='/admin/estimates'></app-header>

    <div v-if='estimate' id='estimate-body'>
      <single-estimate-owner :estimate='estimate' @changed='(payload) => handleUpdate(payload)'></single-estimate-owner>

      <section class='estimate-section'>
        <single-estimate-customer :estimate='estimate' @changed='(payload) => handleUpdate(payload)'></single-estimate-customer>
      </section>

      <section class='estimate-section'>
        <single-estimate-addresses :estimate='estimate' @changed='(payload) => handleUpdate(payload)'></single-estimate-addresses>
      </section>
    </div>
  </page-template>
</template>

<script>
import Owner from '../components/singleEstimate/owner';
import Customer from '../components/singleEstimate/customer';
import Addresses from '../components/singleEstimate/addresses';

export default {
  components: {
    'single-estimate-owner': Owner,
    'single-estimate-customer': Customer,
    'single-estimate-addresses': Addresses
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
          console.log(response);
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

  .estimate-section {
    margin-top: 16px;
  }
</style>
