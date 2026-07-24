<template>
  <b-nav-item-dropdown
    v-if="active > 0 || failed > 0"
    right
    no-caret
    class="upload-indicator"
    menu-class="upload-indicator__menu"
  >
    <template v-slot:button-content>
      <b-spinner v-if="active > 0 && failed === 0" small class="upload-indicator__spinner"></b-spinner>
      <b-icon v-else-if="failed > 0" icon="exclamation-triangle-fill" class="upload-indicator__alert"></b-icon>
      <span class="upload-indicator__badge" :class="{ 'upload-indicator__badge--error': failed > 0 }">
        {{ failed > 0 ? failed : active }}
      </span>
      <span class="upload-indicator__label">Uploads</span>
    </template>

    <b-dropdown-header>
      {{ active }} uploading<span v-if="failed > 0">, {{ failed }} failed</span>
    </b-dropdown-header>

    <li v-for="item in items" :key="item.id" class="upload-indicator__item">
      <div class="upload-indicator__info">
        <div class="upload-indicator__name">{{ item.name }}</div>
        <div class="upload-indicator__status" :class="{ 'upload-indicator__status--error': item.isError }">
          {{ item.label }}<span v-if="item.progress && !item.isError"> · {{ item.progress }}%</span>
        </div>
      </div>
      <div class="upload-indicator__actions">
        <b-icon
          v-if="item.canRetry"
          icon="arrow-clockwise"
          class="upload-indicator__action"
          title="Retry"
          @click.stop="retry(item.id)"
        ></b-icon>
        <b-icon
          icon="x-circle"
          class="upload-indicator__action"
          title="Remove"
          @click.stop="remove(item.id)"
        ></b-icon>
      </div>
    </li>
  </b-nav-item-dropdown>
</template>

<script>
const LABELS = {
  idle: 'Queued',
  compressing: 'Preparing…',
  preparing: 'Preparing…',
  uploading: 'Uploading…',
  finalizing: 'Finishing…',
  pendingAssociation: 'Saving…',
  retryableError: 'Retrying…',
  fatalError: 'Failed'
};

// Statuses worth showing in the indicator. 'awaitingTarget' is intentionally
// excluded: the S3 upload is fully complete and the job is only parked until
// its quote form is submitted. Counting it here would leave images from an
// abandoned form pinned in the "uploading" indicator forever — so we drop them
// from the indicator the moment the upload itself finishes.
const VISIBLE = new Set(Object.keys(LABELS));

export default {
  data() {
    return {
      active: 0,
      failed: 0,
      items: []
    };
  },
  methods: {
    // Counts/items are derived straight from the visible jobs (not the manager
    // summary) so 'awaitingTarget' jobs are excluded from the badge as well.
    refresh() {
      const jobs = this.$uploads.allJobs().filter(job => VISIBLE.has(job.status));
      this.failed = jobs.filter(job => job.status === 'fatalError').length;
      this.active = jobs.filter(job => job.status !== 'fatalError').length;
      this.items = jobs.map(job => ({
        id: job.id,
        name: job.file?.name ?? 'Image',
        status: job.status,
        label: LABELS[job.status] ?? job.status,
        progress: job.progress,
        isError: job.status === 'fatalError',
        canRetry: job.status === 'fatalError' || job.status === 'retryableError'
      }));
    },
    retry(id) {
      this.$uploads.retry(id);
    },
    remove(id) {
      this.$uploads.remove(id);
    }
  },
  mounted() {
    this._unsub = this.$uploads.subscribe(() => this.refresh());
  },
  beforeDestroy() {
    if (this._unsub) this._unsub();
  }
};
</script>

<style scoped>
.upload-indicator__spinner {
  color: var(--main-color);
  margin-right: var(--space-1);
}

.upload-indicator__alert {
  color: var(--danger);
  margin-right: var(--space-1);
}

.upload-indicator__badge {
  display: inline-block;
  min-width: 18px;
  padding: 0 var(--space-1);
  border-radius: var(--radius-pill);
  background: var(--main-color);
  color: #fff;
  font-size: var(--text-xs);
  text-align: center;
  margin-right: var(--space-1);
}

.upload-indicator__badge--error {
  background: var(--danger);
}

.upload-indicator__label {
  font-size: var(--text-base);
}

.upload-indicator__item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-4);
  min-width: 240px;
}

.upload-indicator__info {
  overflow: hidden;
}

.upload-indicator__name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: var(--text-sm);
}

.upload-indicator__status {
  font-size: var(--text-xs);
  color: var(--text-muted);
}

.upload-indicator__status--error {
  color: var(--danger);
}

.upload-indicator__actions {
  display: flex;
  gap: var(--space-2);
  flex-shrink: 0;
}

.upload-indicator__action {
  color: var(--main-color);
  font-size: var(--text-lg);
  cursor: pointer;
}
</style>
