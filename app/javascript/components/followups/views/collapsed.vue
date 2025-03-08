<template>
  <div>
    <app-collapsable id='followups-collapse'>
      <template v-slot:title>
        <b>Followups</b>
      </template>

      <template v-slot:content>
        <b-row class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>No Response</b>
          </b-col>
          <b-col cols='8'>
            {{ sentStatus(estimate.followup_sent_at )}}
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Image/Meeting</b>
          </b-col>
          <b-col cols='8'>
            {{ sentStatus(estimate.picture_request_sent_at )}}
          </b-col>
        </b-row>

        <div class='single-estimate-link-row' v-if="hasPermission('estimates', 'update')">
          <div class='single-estimate-link' v-b-toggle.image-request>
            Image/Meeting
          </div>

          <div class='single-estimate-link' v-b-toggle.no-response>
            No Response
          </div>
        </div>
      </template>
    </app-collapsable>

    <estimate-image-request
      id='image-request'
      :estimate='estimate'
    ></estimate-image-request>

    <estimate-no-response
      id='no-response'
      :estimate='estimate'
    ></estimate-no-response>
  </div>
</template>

<script>
import SendImageRequest from '@/components/followups/actions/imageRequest';
import SendNoResponse from '@/components/followups/actions/noResponse';

export default {
  components: {
    'estimate-image-request': SendImageRequest,
    'estimate-no-response': SendNoResponse
  },
  props: {
    estimate: {
      required: true
    }
  },
  methods: {
    sentStatus(followupTimestamp) {
      if(followupTimestamp != null && followupTimestamp != undefined) {
        var localizeDate = this.$options.filters.localizeDate;
        return `Sent on ${localizeDate(followupTimestamp)}`;
      }
      return 'Not Sent'
    }
  }
}
</script>
