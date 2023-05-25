<template>
  <page-template>
    <app-header
      :title='getTitle()'
      backLink='/admin/estimates'
    ></app-header>

    <div v-if='estimate' id='estimate-body'>

      <div id='estimate-body-left'>
        <section class='estimate-section mobile-only'>
          <single-estimate-owner
            :estimate='estimate'
          ></single-estimate-owner>
        </section>

        <section class='estimate-section'>
          <single-estimate-timeline :estimate='estimate'></single-estimate-timeline>
        </section>

        <section class='estimate-section'>
          <single-estimate-customer :estimate='estimate' :isParentCustomer='true'></single-estimate-customer>
        </section>

         <section class='estimate-section'>
          <single-estimate-customer :estimate='estimate'></single-estimate-customer>
        </section>

        <section class='estimate-section'>
          <single-estimate-addresses :estimate='estimate'></single-estimate-addresses>
        </section>

        <section class='estimate-section'>
          <single-estimate-site :estimate='estimate'></single-estimate-site>
        </section>

        <section class ='estimate-section' v-if='estimate.quote_sent_date'>
          <single-estimate-quotes :estimate='estimate'></single-estimate-quotes>
        </section>

        <section class='estimate-section' v-if='estimate.invoice && estimate.invoice.sent_at'>
          <single-estimate-invoice :estimate='estimate'></single-estimate-invoice>
        </section>

        <section class ='estimate-section' v-if='estimate.costs && estimate.costs.length > 0'>
          <single-estimate-costs :estimate='estimate'></single-estimate-costs>
        </section>

        <section class ='estimate-section'>
          <single-estimate-trees :estimate='estimate'></single-estimate-trees>
        </section>
      </div>

      <div id='estimate-body-left'>
        <section class='estimate-section desktop-only'>
          <single-estimate-owner
            :estimate='estimate'
          ></single-estimate-owner>
        </section>

        <section class ='estimate-section'>
          <single-estimate-followups :estimate='estimate'></single-estimate-followups>
        </section>

        <section class ='estimate-section'>
          <single-estimate-equipment :estimate='estimate'></single-estimate-equipment>
        </section>

        <section class ='estimate-section'>
          <single-estimate-notes :estimate='estimate'></single-estimate-notes>
        </section>

        <section class ='estimate-section' id='status-container'>
          <single-estimate-actions :estimate='estimate'></single-estimate-actions>
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
import EquipmentRequirements from '@/components/tools/views/collapsed';
import Notes from '@/components/notes/views/collapsed';

import EventBus from '@/store/eventBus';

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
    'single-estimate-followups': Followups,
    'single-estimate-equipment': EquipmentRequirements,
    'single-estimate-notes': Notes
  },
  data() {
    return {
      estimate_id: this.$route.params.estimate_id,
      estimate: null,
      updateHandler: null
    }
  },
  mounted() {
    this.retrieveEstimate();
    this.updateHandler = (payload) => this.handleUpdate(payload);
    EventBus.$on('ESTIMATE_UPDATED', this.updateHandler)
  },
  beforeDestroy() {
    console.log("REMOVE");
    EventBus.$off('ESTIMATE_UPDATED', this.updateHandler)
  },
  methods: {
    retrieveEstimate() {
      this.axiosGet(`/estimates/${this.estimate_id}.json`)
        .then(response => {
          this.estimate = response.data.estimate;
        }).catch(
          (error) => {
            this.$router.push('/admin/estimates');
          }
        )
    },
    handleUpdate(payload) {
      if(payload.estimate) {
        this.estimate = payload.estimate
      }
      else{
        this.estimate = Object.assign({}, this.estimate, payload);
      }
    },
    getTitle() {
      var title = "Estimate #" + this.estimate_id;

      if(this.estimate && this.estimate.is_unknown){
        title += ' (Unknown)';
      }

      return title;
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
