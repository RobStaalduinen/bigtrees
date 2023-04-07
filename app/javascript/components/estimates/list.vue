<template>
<div>

  <div id='estimate-search-controls' v-if='!mySchedule'>
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
      page: 1,
      totalEntries: 1,
      status: 'active',
      filters: { createdAfter: 'six_months', status: 'active' }
    }
  },
  computed: mapState({
    estimates: state => state.estimates,
    mySchedule: state => state.estimateSettings.mySchedule
  }),
  methods: {
    retrieveEstimates() {
      if(this.loadingEstimates == true) {
        return
      }
      this.loadingEstimates = true;
      this.error = false;

      var params = {}
      if(!this.mySchedule) {
        params = {
          page: this.page,
          per_page: this.perPage,
          created_after: this.filters.createdAfter,
          status: this.filters.status
        }
      }
      else {
        var params = {
          page: 1,
          per_page: 1000,
          only_mine: true,
          status: 'scheduled'
        }
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
      localStorage.setItem('estimate-filtering-params', JSON.stringify(allFiltering));
    },
    refreshFiltering() {
      var oldFilters = JSON.parse(localStorage.getItem('estimate-filtering-params'))
      if(oldFilters != null) {
        this.page = (oldFilters.page || 1);
        this.searchTerm = oldFilters.searchTerm;
        this.filters = (oldFilters.filters || { createdAfter: 'six_months', status: 'active' });
      }
    },
    resetFiltering() {
      this.searchTerm = null;
      this.page = 1;
      this.filters = { createdAfter: 'six_months', status: 'active' };
      // this.retrieveEstimates();
    }
  },
  created() {
    // this.refreshFiltering();
  },
  mounted() {
    this.retrieveEstimates();
    EventBus.$on('ESTIMATE_UPDATED', this.retrieveEstimates)
  },
  beforeDestroy() {
    EventBus.$off('ESTIMATE_UPDATED', this.retrieveEstimates)
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
