<template>
  <div>
    <app-collapsable id='site-collapse'>
      <template v-slot:title>
        <b>Site Details</b>
      </template>

      <template v-slot:content>
        <template v-if='estimate.site.survey_filled_out'>
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
        </template>
        <template v-else>
          No Survey Filled out
        </template>

        <template v-if='estimate.site_visit_tag'>
          <b-row class='spaced-row'>
            <b-col cols='6' class='right-column'>
              <b>Solo Visit Consent</b>
            </b-col>
            <b-col cols='6'>
              {{ formatAnswer(estimate.site.visit_consent) }}
            </b-col>
          </b-row>

          <b-row class='spaced-row'>
            <b-col cols='6' class='right-column'>
              <b>Site Visit Notes</b>
            </b-col>
            <b-col cols='6'>
              {{ estimate.site.visit_times }}
            </b-col>
          </b-row>
        </template>

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
import EventBus from '@/store/eventBus';

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
      var params = { tree_site: this.site }
      params.tree_site.survey_filled_out = true;

      this.axiosPut(`/estimates/${this.estimate.id}/sites/${this.estimate.site.id}`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', 'site-edit');
        EventBus.$emit('ESTIMATE_UPDATED',  { site: response.data.site });
      })
    }
  }
}
</script>

<style scoped>

</style>
