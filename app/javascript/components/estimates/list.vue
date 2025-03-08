<template>
<div>

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

  <div id='estimates-container'>
    <app-single-estimate v-for='estimate in estimates' :key='estimate.id' :estimate='estimate'></app-single-estimate>
    <app-loading-overlay v-if='loadingEstimates'></app-loading-overlay>
    <div v-if='error'>Something bad happened</div>
  </div>

  <app-estimate-filters modalId='Filters' v-model='filters'></app-estimate-filters>
  <app-list-action-handler></app-list-action-handler>
</div>

</template>

<script>
import SingleEstimate from './single';
import ImageGallery from '@/components/tree_images/views/galleryModal';
import Filters from './filters';
import ListActionHandler from '@/components/estimate/utils/listActionHandler';
import { mapState } from 'vuex'
import EventBus from '@/store/eventBus'

export default {
  components: {
    'app-single-estimate': SingleEstimate,
    'app-estimate-filters': Filters,
    'app-image-gallery': ImageGallery,
    'app-list-action-handler': ListActionHandler
  },
  data() {
    return {
      error: false,
      loadingEstimates: false,
      searchTerm: null,
      perPage: 60,
      page: null,
      totalEntries: 1,
      status: 'active',
      filters: { status: 'active', createdAfter: 'one_year' },
      filteringLoaded: false
    }
  },
  computed: mapState({
    estimates: state => state.estimates
  }),
  methods: {
    retrieveEstimates() {
      if(this.loadingEstimates == true || this.filteringLoaded == false) {
        return
      }
      this.loadingEstimates = true;
      this.error = false;

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
          this.$store.commit('setEstimates', response.data.estimates)
          this.totalEntries = response.data.meta.total_entries;
          this.loadingEstimates = false;
        }).catch(
          (error) => {
            this.loadingEstimates = false;
            this.error = true;
          }
        )
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
      localStorage.setItem('estimateSearchParams', JSON.stringify(allFiltering));
    },
    loadFiltering() {
      let presetFilters = JSON.parse(localStorage.getItem('estimateSearchParams'));
      if(presetFilters != null) {
        this.page = presetFilters.page || 1;
        this.searchTerm = presetFilters.searchTerm;
        this.filters = presetFilters.filters || { status: 'active', createdAfter: 'one_year' };
      }
      else {
        this.page = 1;
        this.searchTerm = null;
        this.filters = { status: 'active', createdAfter: 'one_year' }
      }

      setTimeout(() => { this.filteringLoaded = true }, 1)
    },
    resetFiltering() {
      this.searchTerm = null;
      this.page = 1;
      this.filters = { createdAfter: 'one_year', status: 'active' };
    }
  },
  mounted() {
    this.loadFiltering();
    EventBus.$on('ESTIMATE_UPDATED', this.retrieveEstimates)
  },
  beforeDestroy() {
    EventBus.$off('ESTIMATE_UPDATED', this.retrieveEstimates)
  },
  watch: {
    searchTerm: function(){
      if(!this.filteringLoaded) { return }
      this.page = 1;
      this.saveFiltering();
      this.retrieveEstimates();
    },
    page: function() {
      if(!this.filteringLoaded) { return }
      this.saveFiltering();
      this.retrieveEstimates();
    },
    filters: function() {
      if(!this.filteringLoaded) { return }
      this.page = 1;
      this.saveFiltering();
      this.retrieveEstimates();
    },
    filteringLoaded() {
      this.retrieveEstimates();
    },
    mySchedule() {
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

  @media(min-width: 760px) {
    #estimate-search-controls {
      position: relative;
      margin-bottom: 8px;
      margin-top: -16px;
      border-width: 0;
    }
  }
</style>
