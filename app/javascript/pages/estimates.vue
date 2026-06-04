<template>
  <page-template>
    <app-header title='Quotes'>
      <template v-slot:header-left>
        <h1 class="page-title">Quotes</h1>
      </template>
      <template v-slot:header-right>
        <div class="header-right">
          <a class="head-link" @click='openDownload' v-if='hasPermission("estimates", "admin")'>
            <b-icon icon='download'></b-icon>
            Tracker
          </a>
          <router-link to="/admin/estimates/new" class="head-link solid">
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
.page-title {
  margin: 0;
  font-size: 21px;
  font-weight: 700;
  letter-spacing: -0.01em;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 4px;
}

.head-link {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  color: var(--main-color);
  font-size: 13.5px;
  font-weight: 600;
  padding: 6px 10px;
  border-radius: 8px;
  cursor: pointer;
  text-decoration: none;
}

.head-link:hover {
  background: #faf7f7;
}

.head-link.solid {
  background: var(--main-color);
  color: #fff;
}

.head-link.solid:hover {
  background: var(--main-color-faded);
}

@media(min-width: 760px) {
  .page-title {
    font-size: 24px;
  }
}
</style>
