<template>
  <page-template>
    <app-header :title='"Estimate #" + estimate_id' backLink='/admin/estimates'></app-header>

    <div v-if='estimate' id='estimate-body'>

      <div id='estimate-body-left'>
        <section class='estimate-section mobile-only'>
          <single-estimate-owner
            :estimate='estimate'
            @changed='(payload) => handleUpdate(payload)'
          ></single-estimate-owner>
        </section>

        <section class='estimate-section'>
          <single-estimate-timeline :estimate='estimate' @changed='(payload) => handleUpdate(payload)'></single-estimate-timeline>
        </section>

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

      <div id='estimate-body-left'>
        <section class='estimate-section desktop-only'>
          <single-estimate-owner
            :estimate='estimate'
            @changed='(payload) => handleUpdate(payload)'
          ></single-estimate-owner>
        </section>

        <section class ='estimate-section'>
          <single-estimate-followups :estimate='estimate' @changed='(payload) => handleUpdate(payload)'></single-estimate-followups>
        </section>

        <section class ='estimate-section' id='status-container'>
          <single-estimate-actions :estimate='estimate' @changed='(payload) => handleUpdate(payload)'></single-estimate-actions>
        </section>
      </div>

    </div>
  </page-template>
</template>

<script>
import Timeline from '../components/estimate/views/timelineCollapsed';
import Owner from '../components/singleEstimate/owner';
import Customer from '../components/singleEstimate/customer';
import Addresses from '../components/singleEstimate/addresses';
import StatusAndActions from '../components/singleEstimate/statusAndActions';
import Site from '../components/singleEstimate/site';
import Invoice from '../components/invoice/views/summary';
import Quote from '../components/quote/views/collapsed';
import Costs from '../components/costs/views/collapsed';
import Trees from '../components/trees/views/collapsed';
import Followups from '../components/followups/views/collapsed';

export default {
  components: {
    'single-estimate-timeline': Timeline,
    'single-estimate-owner': Owner,
    'single-estimate-customer': Customer,
    'single-estimate-addresses': Addresses,
    'single-estimate-actions': StatusAndActions,
    'single-estimate-site': Site,
    'single-estimate-invoice': Invoice,
    'single-estimate-quotes': Quote,
    'single-estimate-costs': Costs,
    'single-estimate-trees': Trees,
    'single-estimate-followups': Followups
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
    padding-bottom: 48px;
  }

  .estimate-section {
    margin-top: 16px;
    width: 100%;
  }

  #status-container {
    width: 100%;
    position: fixed;
    bottom: 0;
    left: 0;
    z-index: 20;
  }

  @media(min-width: 760px) {
    #estimate-body {
      display: flex;
    }

    #estimate-body-left {
      width: 50%;
      display: flex;
      flex-direction: column;
      margin-right: 16px;
    }

    #estimate-body-right {
      width: 50%;
      display: flex;
      flex-direction: column;
      margin-left: 16px;
    }

    #status-container {
      position: relative;
      border: 1px lightgray solid;
    }
  }
</style>
