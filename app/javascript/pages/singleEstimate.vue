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

      <section class='estimate-section'>
        <single-estimate-site :estimate='estimate' @changed='(payload) => handleUpdate(payload)'></single-estimate-site>
      </section>

      <section class ='estimate-section' v-if='estimate.quote_sent_date'>
        <single-estimate-quotes :estimate='estimate'></single-estimate-quotes>
      </section>

      <section class='estimate-section' v-if='estimate.invoice && estimate.invoice.sent_at'>
        <single-estimate-invoice :estimate='estimate' @changed='(payload) => handleUpdate(payload)'></single-estimate-invoice>
      </section>

      <section class ='estimate-section'>
        <single-estimate-costs :estimate='estimate' @changed='(payload) => handleUpdate(payload)'></single-estimate-costs>
      </section>

      <section class ='estimate-section'>
        <single-estimate-trees :estimate='estimate' @changed='(payload) => handleUpdate(payload)'></single-estimate-trees>
      </section>
    </div>
  </page-template>
</template>

<script>
import Owner from '../components/singleEstimate/owner';
import Customer from '../components/singleEstimate/customer';
import Addresses from '../components/singleEstimate/addresses';
import Site from '../components/singleEstimate/site';
import Invoice from '../components/invoice/views/summary';
import Quote from '../components/quote/views/collapsed';
import Costs from '../components/costs/views/collapsed';
import Trees from '../components/trees/views/collapsed';

export default {
  components: {
    'single-estimate-owner': Owner,
    'single-estimate-customer': Customer,
    'single-estimate-addresses': Addresses,
    'single-estimate-site': Site,
    'single-estimate-invoice': Invoice,
    'single-estimate-quotes': Quote,
    'single-estimate-costs': Costs,
    'single-estimate-trees': Trees
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
      if(payload.estimate) {
        this.estimate = payload.estimate
      }
      else{
        this.estimate = Object.assign({}, this.estimate, payload);
      }
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
