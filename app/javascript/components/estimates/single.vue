<template>
  <div class='shadow-box-entry estimate'>
    <!-- Header doubles as the link into the quote -->
    <router-link class='estimate-header' :to='estimateLink'>
      <div class='estimate-header-left'>
        <span class='estimate-header-name'>{{ estimate.customer_detail.name }}</span>
        <span v-if='priority' class='priority-badge' :class='priorityBadgeClass'>Prio {{ priority }}</span>
      </div>
      <div class='estimate-header-right'>
        <span class='estimate-status'>
          <span class='dot' :class='stateDotClass'></span>
          <span v-if='stateLabel' class='estimate-state-note'>({{ stateLabel }})</span>
          {{ estimate.formatted_status }}
        </span>
        <b-icon icon='chevron-right' class='estimate-chevron'></b-icon>
      </div>
    </router-link>

    <!-- Meta strip: difficulty + last email action -->
    <div class='estimate-meta'>
      <app-pill icon='bar-chart-fill' :text='estimate.difficulty' :tone='difficultyTone' filled capitalize clickable v-b-toggle='difficultySidebarId' role='button'></app-pill>
      <span class='email-chip' :class="{ 'email-chip-empty': !lastEmail }">
        <b-icon :icon="lastEmail ? 'envelope-fill' : 'envelope'"></b-icon>
        <template v-if='lastEmail'><b>{{ formatKey(lastEmail.template_key) }}</b> · {{ lastEmail.sent_at | moment('from', 'now') }}</template>
        <template v-else>No email sent yet</template>
      </span>
      <b-icon v-if='estimate.has_images' icon='images' class='images-icon' title='Has images'></b-icon>
    </div>

    <div class='estimate-body'>
      <div class='estimate-body-row' v-if='mySchedule'>
        <b-icon icon='clock' class='contact-icon'></b-icon>
        {{ estimate.work_start_date | localizeDate }} - {{ estimate.work_end_date | localizeDate }}
      </div>

      <div class='estimate-parent' v-if='estimate.customer.name != estimate.customer_detail.name'>
        Parent: {{ estimate.customer.name }}
      </div>

      <div class='estimate-body-row' v-if='estimate.site && estimate.site.address'>
        <b-icon icon='globe' class='contact-icon'></b-icon>
        <a :href="'http://maps.google.com/?q=' + encodeURIComponent(estimate.site.address.full_address)" target='_blank'>
          {{ estimate.site.address.full_address }}
        </a>
      </div>

      <div class='estimate-body-row'>
        <b-icon icon='telephone' class='contact-icon'></b-icon>
        <a :href="'tel:' + estimate.customer_detail.phone">{{ estimate.customer_detail.phone }}</a>
        <b-icon icon='envelope' class='contact-icon email-icon'></b-icon>
        <a :href="'mailto:' + estimate.customer_detail.email">{{ estimate.customer_detail.email }}</a>
      </div>
    </div>

    <div class='estimate-footer'>
      <div class='estimate-footer-left tags-edit' v-b-toggle='tagsSidebarId' role='button'>
        <app-tag-list v-if='estimate.tags.length' :tags='estimate.tags' :collapsed="true"></app-tag-list>
        <span v-else class='tags-empty'><i>+ Add tag</i></span>
      </div>

      <div class='estimate-footer-right'>
        <app-estimate-actions-list :estimate='estimate'></app-estimate-actions-list>
      </div>
    </div>

    <app-edit-tags :id='tagsSidebarId' :estimate='estimate'></app-edit-tags>
    <app-edit-difficulty :id='difficultySidebarId' :estimate='estimate'></app-edit-difficulty>

  </div>
</template>

<script>
import TimelineModal from './timelineModal';
import ActionsList from './actionsList';
import { mapState } from 'vuex'
import TagList from '@/components/tags/views/list.vue'
import EditTags from '@/components/tags/views/editEstimateTags.vue'
import EditDifficulty from '@/components/estimateState/actions/editDifficulty.vue'
import { difficultyTone } from '@/lib/estimateTones'

export default {
  props: {
    'estimate':{
      type: Object,
      required: true
    }
  },
  components: {
    'app-timeline-modal': TimelineModal,
    'app-estimate-actions-list': ActionsList,
    'app-tag-list': TagList,
    'app-edit-tags': EditTags,
    'app-edit-difficulty': EditDifficulty
  },
  computed: {
    ...mapState({
      mySchedule: state => state.estimateSettings.mySchedule
    }),
    estimateLink() {
      return `/admin/estimates/${this.estimate.id}`;
    },
    tagsSidebarId() {
      return `edit-tags-sidebar-${this.estimate.id}`;
    },
    difficultySidebarId() {
      return `edit-difficulty-sidebar-${this.estimate.id}`;
    },
    priority() {
      return this.estimate.customer && this.estimate.customer.priority;
    },
    priorityBadgeClass() {
      return `priority-badge-${this.priority}`;
    },
    stateDotClass() {
      return `dot-state-${this.estimate.state}`;
    },
    // Surface the state alongside the status only when it adds info the
    // status doesn't already convey (unknown / on hold).
    stateLabel() {
      const labels = { unknown: 'Unknown', on_hold: 'On Hold' };
      return labels[this.estimate.state] || '';
    },
    difficultyTone() {
      return difficultyTone(this.estimate.difficulty);
    },
    // Most recent email sent to the customer, from the email_records association
    // (serialized as { template_key, sent_at }).
    lastEmail() {
      return this.estimate.last_email || null;
    }
  },
  methods: {
    // Humanize a template_key, e.g. "quote_mailout" -> "Quote Mailout".
    // Mirrors the formatting used in the Email History view.
    formatKey(key) {
      if (!key) { return ''; }
      return key.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase());
    }
  }
}
</script>

<style scoped>
  .estimate {
    width: 100%;
    margin-bottom: 8px;
    display: flex;
    flex-direction: column;
    font-size: 12px;
  }

  /* ---- Header (tap target into the quote) ---- */
  .estimate-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    padding: 6px 10px;
    border-bottom: 1px solid #eee;
    color: inherit;
    text-decoration: none;
  }

  .estimate-header:hover {
    background-color: #fcf7f7;
  }

  .estimate-header-left {
    display: flex;
    align-items: center;
    gap: 7px;
    min-width: 0;
  }

  .estimate-header-name {
    font-weight: 700;
    font-size: 13.5px;
    color: var(--main-color);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .estimate-header-right {
    display: flex;
    align-items: center;
    gap: 6px;
    flex: 0 0 auto;
  }

  .estimate-status {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    color: var(--secondary-red);
    font-weight: 700;
    font-size: 11px;
    white-space: nowrap;
  }

  .estimate-state-note {
    color: #888;
    font-weight: 600;
  }

  .estimate-chevron {
    color: #bbb;
    font-size: 13px;
  }

  .dot {
    width: 9px;
    height: 9px;
    border-radius: 50%;
    display: inline-block;
    flex: 0 0 auto;
  }

  .dot-state-in_progress { background-color: #3b82f6; }
  .dot-state-on_hold     { background-color: #f59e0b; }
  .dot-state-done        { background-color: #10b981; }
  .dot-state-unknown     { background-color: #9ca3af; }
  .dot-state-cancelled   { background-color: #ef4444; }

  /* ---- Priority badge (mirrors the detail header) ---- */
  .priority-badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 0.78em;
    font-weight: 700;
    color: #3a2e15;
    border: 1px solid rgba(0, 0, 0, 0.15);
    white-space: nowrap;
  }

  .priority-badge-1 { background: linear-gradient(135deg, #ffe066, #d4af37); }
  .priority-badge-2 { background: linear-gradient(135deg, #f5e7a8, #e0c46c); }
  .priority-badge-3 { background: linear-gradient(135deg, #e8e8e8, #b8b8b8); }
  .priority-badge-4 { background: linear-gradient(135deg, #dcae84, #b8763e); color: #2e1a0a; }
  .priority-badge-5 { background: linear-gradient(135deg, #c68a52, #8b4e1f); color: #fff; }

  /* ---- Meta strip ---- */
  .estimate-meta {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 9px;
    padding: 5px 10px;
    background-color: #fafafa;
    border-bottom: 1px solid #eee;
  }

  .email-chip {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    font-size: 11.5px;
    color: #555;
  }

  .email-chip >>> .b-icon { color: #9a9a9a; }
  .email-chip b { color: #444; font-weight: 600; }
  .email-chip-empty { color: #aaa; }

  .images-icon {
    margin-left: auto;
    color: var(--main-color);
    font-size: 13px;
  }

  /* ---- Body ---- */
  .estimate-body {
    display: flex;
    flex-direction: column;
    gap: 4px;
    padding: 6px 10px;
  }

  .estimate-body-row {
    display: flex;
    align-items: center;
  }

  .estimate-parent {
    color: #777;
    font-size: 11px;
  }

  .contact-icon {
    color: var(--main-color);
    margin-right: 6px;
  }

  .email-icon {
    margin-left: 16px;
  }

  /* ---- Footer ---- */
  .estimate-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid #eee;
    padding-left: 10px;
  }

  .estimate-footer-left {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 5px;
    padding: 5px 0;
  }

  .tags-edit {
    cursor: pointer;
    padding: 5px 6px;
    border-radius: 4px;
    transition: background-color 0.15s;
  }

  .tags-edit:hover {
    background-color: #ececec;
  }

  .tags-empty {
    color: #999;
  }

  .estimate-footer-right {
    display: flex;
    justify-content: flex-end;
  }
</style>
