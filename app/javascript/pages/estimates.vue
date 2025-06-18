<template>
  <page-template>
    <app-header title='Quotes'>
      <template v-slot:header-right>
        <div class="header-right">
          <a @click='openDownload' v-if='hasPermission("estimates", "admin")'>
            <b-icon icon='download'></b-icon>
            Tracker
          </a>
          <div class="header-divider">
            |
          </div>
          <router-link to="/admin/estimates/new" class="header-link">
            <b-icon icon="plus"></b-icon>
            New
          </router-link>
        </div>
      </template>

    </app-header>

    <app-estimate-list></app-estimate-list>

    <b-modal
      id="tracker-download"
      size="md"
      title="Download Tracker"
      @hide="close"
      ok-only
      ok-title="Close"
      >
        <app-tracker-download></app-tracker-download>

    </b-modal>
  </page-template>
</template>

<script>
import EstimateList from '../components/estimates/list';
import DownloadTracker from '../components/tracker/actions/filteredDownload.vue';

export default {
  components: {
    'app-estimate-list': EstimateList,
    'app-tracker-download': DownloadTracker,
  },
  methods: {
    openDownload() {
      this.$bvModal.show('tracker-download');
    },
    close() {
      this.$bvModal.hide('tracker-download');
    },
  }
}
</script>

<style scoped>
.header-right {
  display: flex;
  align-items: center;
}

.header-divider {
  margin: 0 8px;
  color: var(--main-color);
}

</style>
