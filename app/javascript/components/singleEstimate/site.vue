<template>
  <div>
    <app-collapsable id='site-collapse'>
      <template v-slot:title>
        <b>Site Details</b>
      </template>

      <template v-slot:content>
        <b-row class='spaced-row'>
          <b-col cols='6' class='right-column'>
            <b>Wood removal</b>
          </b-col>
          <b-col cols='6'>
            {{ formatAnswer(estimate.site.wood_removal) }}
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='6' class='right-column'>
            <b>Complete Cleanup</b>
          </b-col>
          <b-col cols='6'>
            {{ formatAnswer(estimate.site.cleanup) }}
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='6' class='right-column'>
            <b>Vehicle Access</b>
          </b-col>
          <b-col cols='6'>
            {{ formatAnswer(estimate.site.vehicle_access) }}
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='6' class='right-column'>
            <b>Breakables</b>
          </b-col>
          <b-col cols='6'>
            {{ formatAnswer(estimate.site.breakables) }}
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='6' class='right-column'>
            <b>Low Access Width</b>
          </b-col>
          <b-col cols='6'>
            {{ formatAnswer(estimate.site.low_access_width) }}
          </b-col>
        </b-row>

        <div class='single-estimate-link-row'>
          <div class='single-estimate-link' v-b-toggle.site-edit>
            <b-icon icon='pencil-square' class='app-icon'></b-icon>
          </div>
        </div>

      </template>
    </app-collapsable>

    <app-right-sidebar id='site-edit' title='Edit Site' submitText='Save' :onSubmit='updateSite'>
      <template v-slot:content>
        <app-site-questions v-model='site'> </app-site-questions>
      </template>
    </app-right-sidebar>
  </div>
</template>

<script>
import SiteForm from '../createEstimate/siteQuestions';

export default {
  components: {
    'app-site-questions': SiteForm
  },
  props: {
    estimate: {
      required: true,
      type: Object
    }
  },
  data() {
    return {
      site: { ...this.estimate.site }
    }
  },
  methods: {
    formatAnswer(answer) {
      return answer ? 'Yes' : 'No';
    },
    updateSite() {
      var params = { site: this.site }
      this.axiosPut(`/estimates/${this.estimate.id}/sites/${this.estimate.site.id}`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', 'site-edit');
        this.$emit('changed', { site: response.data.site });
      })
    }
  }
}
</script>

<style scoped>

</style>
