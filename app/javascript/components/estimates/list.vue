<template>
<div>
  <div id='estimates-container'>
    <app-single-estimate v-for='estimate in estimates' :key='estimate.id' :estimate='estimate' @estimateChanged='retrieveEstimates()'></app-single-estimate>
    <app-loading-overlay v-if='loadingEstimates'></app-loading-overlay>
  </div>
    <div id='estimate-search-controls'>
      <div id='search-container'>
        <div id='search-field-container'>
          <app-search-field v-model='searchTerm'></app-search-field>
        </div>
        <app-button text='Reset' :click='resetFiltering'></app-button>
        <app-button text='Filters' icon='filter' v-b-modal='"Filters"'></app-button>
      </div>
      <app-arrow-pagination :totalEntries='totalEntries' :perPage='perPage' v-model='page'></app-arrow-pagination>
    </div>

  <app-estimate-filters modalId='Filters' v-model='filters'></app-estimate-filters>
</div>

</template>

<script>
import SingleEstimate from './single';
import Filters from './filters';
import { mapState } from 'vuex'

export default {
  components: {
    'app-single-estimate': SingleEstimate,
    'app-estimate-filters': Filters
  },
  data() {
    return {
      loadingEstimates: true,
      searchTerm: null,
      perPage: 20,
      page: 1,
      totalEntries: 1,
      status: 'all',
      filters: { createdAfter: 'six_months', status: 'all' }
    }
  },
  computed: mapState({
    estimates: state => state.estimates,
  }),
  methods: {
    retrieveEstimates() {
      this.loadingEstimates = true;

      var params = {
        page: this.page,
        per_page: this.perPage,
        created_after: this.filters.createdAfter,
        status: this.filters.status
      }

      if(this.searchTerm != null) {
        params['q'] = this.searchTerm
      }
      this.axiosGet(`/estimates.json`, params)
          .then(response => {
            console.log(response.data);
            this.$store.commit('setEstimates', response.data.estimates)
            this.totalEntries = response.data['total_entries'];
            this.loadingEstimates = false;
          })
    },
    changeFilters(new_filters) {
      this.filters = new_filters;
      this.retrieveEstimates();
    },
    saveFiltering() {
      var allFiltering = {
        page: this.page,
        searchTerm: this.searchTerm,
        filters: this.filters
      };
      localStorage.setItem('estimate-filtering-params', JSON.stringify(allFiltering));
    },
    refreshFiltering() {
      var oldFilters = JSON.parse(localStorage.getItem('estimate-filtering-params'))
      if(oldFilters != null) {
        this.page = (oldFilters.page || 1);
        this.searchTerm = oldFilters.searchTerm;
        this.filters = (oldFilters.filters || { createdAfter: 'six_months', status: 'all' });
      }
    },
    resetFiltering() {
      this.searchTerm = null;
      this.page = 1;
      this.filters = { createdAfter: 'six_months', status: 'all' };
      this.retrieveEstimates();
    }
  },
  created() {
    this.refreshFiltering();
  },
  mounted() {
    this.retrieveEstimates();
  },
  watch: {
    searchTerm: function(){
      this.page = 1;
      this.saveFiltering();
      this.retrieveEstimates();
    },
    page: function() {
      this.saveFiltering();
      this.retrieveEstimates();
    },
    filters: function() {
      this.page = 1;
      this.saveFiltering();
      this.retrieveEstimates();
    }
  }
}
</script>

<style scoped>
  #estimates-container {
    position: relative;

    padding-bottom: 64px;
  }

  #estimate-search-controls{
    position: fixed;
    bottom: 0;
    left: 0;
    z-index: 20;
    width: 100%;
    
    background-color: white;
    border-top: 4px var(--main-color) solid;
  }

  #search-container {
    padding: 8px;
    display: flex;
    justify-content: space-between;
  }

  #search-field-container {
    width: 60%;
  }
</style>
