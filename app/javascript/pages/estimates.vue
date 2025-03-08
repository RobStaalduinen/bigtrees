<template>
  <page-template>
    <app-header title='Quotes'>
      <template v-slot:header-right>
        <div class="header-right">
          <a @click='downloadTracker' v-if='hasPermission("estimates", "admin")'>
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
  </page-template>
</template>

<script>
import EstimateList from '../components/estimates/list';
import { store } from '@/store/store'

export default {
  components: {
    'app-estimate-list': EstimateList
  },
  methods: {
    downloadTracker() {
      this.axiosDownload('/trackers.xlsx', 'MasterTracker.xlsx')
    }
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
