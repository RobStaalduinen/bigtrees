<template>
  <div>
    <app-collapsable id='email-history-collapse'>
      <template v-slot:title>
        <b>Email History ({{ emailRecords.length }})</b>
      </template>

      <template v-slot:content>
        <div v-if='loading' class='empty-state'>Loading…</div>

        <div v-else-if='emailRecords.length === 0' class='empty-state'>
          No emails sent yet.
        </div>

        <div v-else>
          <div v-for='record in emailRecords' :key='record.id' class='email-row'>
            <div class='email-row-title'>{{ formatKey(record.template_key) }}</div>
            <div class='email-row-meta'>
              <span class='email-row-recipient' v-if='record.recipient_email'>
                {{ record.recipient_email }}
              </span>
              <span class='email-row-time'>{{ formatSentAt(record.sent_at) }}</span>
            </div>
          </div>
        </div>

        <div class='single-estimate-link-row' v-if="hasPermission('estimates', 'update')">
          <div class='single-estimate-link' v-b-toggle.send-followup>
            Send Followup
          </div>
        </div>
      </template>
    </app-collapsable>

    <estimate-send-followup
      id='send-followup'
      :estimate='estimate'
      @sent='retrieveEmailRecords'
    ></estimate-send-followup>
  </div>
</template>

<script>
import SendFollowup from '@/components/emailHistory/actions/sendFollowup';
import EventBus from '@/store/eventBus';
import moment from 'moment';

export default {
  components: {
    'estimate-send-followup': SendFollowup
  },
  props: {
    estimate: {
      required: true
    }
  },
  data() {
    return {
      emailRecords: [],
      loading: true,
      updateHandler: null
    }
  },
  methods: {
    retrieveEmailRecords() {
      this.axiosGet(`/estimates/${this.estimate.id}/email_records`).then(response => {
        this.emailRecords = response.data.email_records;
        this.loading = false;
      })
    },
    formatKey(key) {
      if (!key) { return ''; }
      return key.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase());
    },
    formatSentAt(timestamp) {
      return moment(timestamp).format('MMM D, YYYY · h:mm a');
    }
  },
  mounted() {
    this.retrieveEmailRecords();
    this.updateHandler = () => this.retrieveEmailRecords();
    EventBus.$on('ESTIMATE_UPDATED', this.updateHandler);
  },
  beforeDestroy() {
    EventBus.$off('ESTIMATE_UPDATED', this.updateHandler);
  }
}
</script>

<style scoped>
  .empty-state {
    font-size: 0.85rem;
    color: #888;
    padding: 8px 4px;
  }

  .email-row {
    display: flex;
    flex-direction: column;
    padding: 8px;
    border: 1px solid lightgray;
    margin: 4px 0;
  }

  .email-row:nth-child(even) {
    background-color: #f8f7f7;
  }

  .email-row-title {
    font-weight: 600;
    margin-bottom: 2px;
  }

  .email-row-meta {
    display: flex;
    justify-content: space-between;
    font-size: 0.8rem;
    color: #555;
  }

  .email-row-recipient {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    margin-right: 8px;
  }

  .email-row-time {
    white-space: nowrap;
  }
</style>
