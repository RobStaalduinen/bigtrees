<template>
  <page-template>
    <app-header title='Quotes'>
      <template v-slot:header-right>
        <a href='/trackers.xlsx' v-if='admin'>
          <b-icon icon='download'></b-icon>
          Tracker
        </a>
      </template>

    </app-header>

    <app-estimate-list></app-estimate-list>
  </page-template>
</template>

<script>
import EstimateList from '../components/estimates/list';

export default {
  components: {
    'app-estimate-list': EstimateList
  },
  data() {
    return {

    }
  },
  computed: {
    admin() {
      return this.$store.state.user.admin;
    },
  }
}
</script>

<style scoped>

</style>
