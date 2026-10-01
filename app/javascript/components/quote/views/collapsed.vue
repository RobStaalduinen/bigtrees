<template>
  <div>
    <app-collapsable id='quote-collapse'>
      <template v-slot:title>
        <b>Quote</b> &nbsp; {{ '- ' + quoteStatus() }}
      </template>

      <template v-slot:content>
        <b-row class='spaced-row' v-if='estimate.quote_sent_date'>
          <b-col cols='4' class='right-column'>
            <b>Sent At</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.quote_sent_date }}
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Valid Until</b>
          </b-col>
          <b-col cols='8'>
            <span v-if='estimate.quote_valid_until'>
              {{ estimate.quote_valid_until | localizeDate }}
            </span>
            <span v-else class='scope-unset'>Not set</span>
            <b-icon
              v-if="hasPermission('estimates', 'update')"
              icon='pencil-square'
              class='app-icon edit-icon valid-until-edit'
              aria-label='Edit the valid until date'
              v-b-toggle.quote-valid-until-edit
            ></b-icon>
          </b-col>
        </b-row>

        <b-row class='spaced-row' v-if='estimate.work_start_date'>
          <b-col cols='4' class='right-column'>
            <b>Work Date</b>
          </b-col>
          <b-col cols='8'>
            {{ estimate.work_start_date | localizeDate }} - {{ estimate.work_end_date | localizeDate }}
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Scope of Work</b>
          </b-col>
          <b-col cols='8'>
            <span v-if='scopeOfWork' class='scope-text'>{{ scopeOfWork }}</span>
            <span v-else class='scope-unset'>Not set</span>
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Included</b>
          </b-col>
          <b-col cols='8'>
            <ul v-if='inclusions.length' class='scope-bullets'>
              <li v-for='(item, index) in inclusions' :key='`inc-${index}`'>{{ item }}</li>
            </ul>
            <span v-else class='scope-unset'>Not set</span>
          </b-col>
        </b-row>

        <b-row class='spaced-row'>
          <b-col cols='4' class='right-column'>
            <b>Excluded</b>
          </b-col>
          <b-col cols='8'>
            <ul v-if='exclusions.length' class='scope-bullets'>
              <li v-for='(item, index) in exclusions' :key='`exc-${index}`'>{{ item }}</li>
            </ul>
            <span v-else class='scope-unset'>Not set</span>
          </b-col>
        </b-row>

        <div class='single-estimate-link-row'>
          <a class='single-estimate-link' :href='`/estimates/${estimate.id}/quotes.pdf`'>
            Download
          </a>
          <div class='single-estimate-link' v-b-toggle.quote-scope-edit v-if="hasPermission('estimates', 'update')">
            Edit Scope
          </div>
          <div class='single-estimate-link' v-b-toggle.quote-send-team v-if="hasPermission('estimates', 'update')">
            Send to Team
          </div>
          <div class='single-estimate-link' v-b-toggle.quote-send v-if="hasPermission('estimates', 'update')">
            {{ estimate.quote_sent_date ? 'Resend' : 'Send' }}
          </div>
        </div>

      </template>
    </app-collapsable>

    <app-quote-send id='quote-send' :estimate='estimate'></app-quote-send>
    <app-quote-send-team id='quote-send-team' :estimate='estimate'></app-quote-send-team>
    <app-quote-scope-edit id='quote-scope-edit' :estimate='estimate'></app-quote-scope-edit>
    <app-quote-valid-until id='quote-valid-until-edit' :estimate='estimate'></app-quote-valid-until>
  </div>
</template>

<script>
import QuoteSend from '../actions/sendInitial';
import QuoteSendTeam from '../actions/sendToTeam';
import QuoteScopeEdit from '../actions/editScope';
import QuoteValidUntil from '../actions/editValidUntil';

export default {
  components: {
    'app-quote-send': QuoteSend,
    'app-quote-send-team': QuoteSendTeam,
    'app-quote-scope-edit': QuoteScopeEdit,
    'app-quote-valid-until': QuoteValidUntil
  },
  props: {
    estimate: {
      required: true
    }
  },
  computed: {
    // quote_scope is absent until the fields are first saved.
    scopeOfWork() {
      return (this.estimate.quote_scope && this.estimate.quote_scope.scope_of_work) || '';
    },
    inclusions() {
      return (this.estimate.quote_scope && this.estimate.quote_scope.inclusions) || [];
    },
    exclusions() {
      return (this.estimate.quote_scope && this.estimate.quote_scope.exclusions) || [];
    }
  },
  methods: {
    quoteStatus() {
      if(this.estimate.work_start_date) {
        return 'Accepted'
      }
      else if(this.estimate.quote_sent_date) {
        return 'Sent'
      }
      else {
        return 'Not Yet Sent'
      }
    }
  }
}
</script>

<style scoped>
  .scope-text {
    white-space: pre-wrap;
  }

  .scope-unset {
    color: gray;
    font-style: italic;
  }

  .scope-bullets {
    margin: 0;
    padding-left: 18px;
  }

  .scope-bullets li {
    margin-bottom: 2px;
  }

  .valid-until-edit {
    margin-left: 8px;
  }
</style>
