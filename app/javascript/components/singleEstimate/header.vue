<template>
  <div class='estimate-header'>
    <div class='chips-row'>
      <app-meta-pill
        icon='person-fill'
        :text='estimate.arborist.name'
        icon-color='var(--main-color)'
        clickable
        v-b-toggle.edit-owner-sidebar
        role='button'
      />

      <app-meta-pill
        icon='circle-fill'
        :text='formatState(estimate.state)'
        :icon-color='stateColor'
        clickable
        v-b-toggle.edit-state-sidebar
        role='button'
      />

      <span class='reason-info' v-if='estimate.state_reason' :id='reasonId' role='button' tabindex='0'>
        <b-icon icon='info-circle'/>
      </span>
      <b-popover v-if='estimate.state_reason' :target='reasonId' triggers='click blur' placement='bottom'>
        <template #title>Reason</template>
        {{ estimate.state_reason }}
      </b-popover>

      <app-meta-pill
        icon='bar-chart-fill'
        :text='estimate.difficulty'
        :fill='estimate.difficulty'
        capitalize
        clickable
        v-b-toggle.edit-difficulty-sidebar
        role='button'
      />
    </div>

    <div class='tags-row' v-b-toggle.edit-tags-sidebar role='button'>
      <template v-if='estimate.tags.length > 0'>
        <app-tag v-for='tag in estimate.tags' :key='tag.id' :tag='tag'/>
      </template>
      <span class='tags-empty' v-else><i>No tags</i></span>
    </div>

    <app-edit-state id='edit-state-sidebar' :estimate='estimate'/>
    <app-edit-difficulty id='edit-difficulty-sidebar' :estimate='estimate'/>
    <app-edit-tags id='edit-tags-sidebar' :estimate='estimate'/>
    <app-edit-owner id='edit-owner-sidebar' :estimate='estimate'/>
  </div>
</template>

<script>
import EditState from '@/components/estimateState/actions/editState.vue';
import EditDifficulty from '@/components/estimateState/actions/editDifficulty.vue';
import EditTags from '@/components/tags/views/editEstimateTags.vue';
import EditOwner from '@/components/singleEstimate/editOwner.vue';
import MetaPill from '@/components/estimates/metaPill.vue';

const STATE_COLORS = {
  in_progress: '#3b82f6',
  on_hold:     '#f59e0b',
  done:        '#10b981',
  unknown:     '#9ca3af',
  cancelled:   '#ef4444'
};

export default {
  components: {
    'app-edit-state': EditState,
    'app-edit-difficulty': EditDifficulty,
    'app-edit-tags': EditTags,
    'app-edit-owner': EditOwner,
    'app-meta-pill': MetaPill
  },
  props: {
    estimate: { required: true, type: Object }
  },
  computed: {
    reasonId() {
      return `state-reason-${this.estimate.id}`;
    },
    stateColor() {
      return STATE_COLORS[this.estimate.state] || '#9ca3af';
    }
  },
  methods: {
    formatState(state) {
      return state.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
    }
  }
}
</script>

<style scoped>
  .estimate-header {
    display: flex;
    flex-direction: column;
    gap: 10px;
    padding: 12px 16px;
    background-color: #fafafa;
    border-bottom: 1px solid lightgray;
  }

  /* On desktop, lay the owner / state / difficulty chips out on a single
     row; tags break to their own line beneath. */
  @media(min-width: 760px) {
    .estimate-header {
      flex-direction: row;
      flex-wrap: wrap;
      align-items: center;
      column-gap: 8px;
    }

    .tags-row {
      flex-basis: 100%;
    }
  }

  .chips-row {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;
  }

  .reason-info {
    display: inline-flex;
    align-items: center;
    color: var(--main-color);
    cursor: pointer;
    margin-left: -4px;
  }

  .tags-row {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 6px;
    cursor: pointer;
    padding: 4px;
    border-radius: 4px;
    transition: background-color 0.15s;
  }

  .tags-row:hover {
    background-color: #ececec;
  }

  .tags-empty {
    color: #888;
    flex: 1;
  }

  /* Compact the tags within the header only (shared ui/tag.vue is untouched).
     Smaller footprint, but heavier weight + letter-spacing keeps them legible. */
  .tags-row >>> .tag {
    padding: 1px 8px;
    border-radius: 6px;
    font-size: 0.85em;
    font-weight: 600;
    letter-spacing: 0.02em;
    line-height: 1.35;
  }
</style>
