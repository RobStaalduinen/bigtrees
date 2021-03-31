<template>
  <app-shadow-box>
    <template v-slot:box-header>
      <h5>Summaries</h5>
    </template>

    <template v-slot:box-body>
      <b-tabs content-class="mt-4" lazy>
        <b-tab title="Days" active>
          <app-single-summary summaryType="days"></app-single-summary>
        </b-tab>
        <b-tab title="Weeks">
          <app-single-summary summaryType="weeks"></app-single-summary>
        </b-tab>
        <b-tab title="Months">
          <app-single-summary summaryType="months"></app-single-summary>
        </b-tab>
        <b-tab title="Years">
          <app-single-summary summaryType="years"></app-single-summary>
        </b-tab>
      </b-tabs>
    </template>
  </app-shadow-box>
</template>

<script>
import SingleSummary from './singleSummary.vue';

export default {
  components: {
    'app-single-summary': SingleSummary
  }
}
</script>

<style scoped>
  #summary-container{
    padding: 8px;
  }
</style>
