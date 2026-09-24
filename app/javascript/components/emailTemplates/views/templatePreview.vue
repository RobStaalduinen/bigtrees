<template>
  <b-modal :id='id' size='lg' title='Preview' ok-only ok-title='Close' @show='seedSelections'>
    <p class='preview-note'>
      Rendered against a fixed sample job for
      <b>{{ sampleCustomerName }}</b>, using your organization's details.
    </p>

    <div v-if='activeInsertables.length > 0' class='preview-insertables'>
      <div class='preview-label'>Insertable Content</div>
      <p class='preview-insertables-note'>
        Switch between the options to see how each version reads. Leaving one blank drops its
        paragraph, which is what happens when nobody picks an option.
      </p>

      <app-select-field
        v-for='insertable in activeInsertables'
        :key='insertable.key'
        :label='insertable.label'
        :value='selections[insertable.key]'
        @input='value => setSelection(insertable.key, value)'
        :name='`preview_${insertable.key.toLowerCase()}`'
        :options='insertableOptions(insertable)'
      />
    </div>

    <div class='preview-field'>
      <div class='preview-label'>Subject</div>
      <div class='preview-subject'>{{ renderedSubject }}</div>
    </div>

    <div class='preview-field'>
      <div class='preview-label'>Body</div>
      <pre class='preview-body'>{{ renderedBody }}</pre>
    </div>
  </b-modal>
</template>

<script>

import { expandBody, expandSubject } from '@/content/emailMacros';
import { findInsertables, applyInsertables } from '@/content/emailInsertables';
import sampleContext from '@/content/sampleEmailContext.json';

export default {
  props: {
    id: {
      required: true
    },
    subject: {
      required: false,
      type: String,
      default: ''
    },
    content: {
      required: false,
      type: String,
      default: ''
    }
  },
  data() {
    return {
      insertables: [],
      selections: {}
    }
  },
  computed: {
    sampleCustomerName() {
      return sampleContext.estimate.customer_detail.name;
    },
    // The preview shows the organization the user is signed in to, so their own name and
    // signature appear; only the job behind the email is invented.
    context() {
      return {
        organization: this.$store.state.organization,
        estimate: sampleContext.estimate
      }
    },
    activeInsertables() {
      return findInsertables(this.content, this.insertables);
    },
    renderedSubject() {
      return expandSubject(this.subject, this.context);
    },
    // Computed rather than rendered on open, so changing a selection redraws the body at once.
    renderedBody() {
      const withInsertables = applyInsertables(this.content, this.insertables, this.selections);

      return expandBody(withInsertables, this.context);
    }
  },
  methods: {
    insertableOptions(insertable) {
      return [
        { value: null, text: '— Nothing selected —' },
        ...(insertable.options || []).map(option => ({ value: option.id, text: option.label }))
      ]
    },
    setSelection(key, value) {
      this.$set(this.selections, key, value);
    },
    // Each open starts from the first option, so the preview opens showing content rather than a
    // gap where the paragraph goes.
    seedSelections() {
      this.selections = this.activeInsertables.reduce((selections, insertable) => {
        const option = (insertable.options || [])[0];

        if (option) { selections[insertable.key] = option.id; }

        return selections;
      }, {});
    },
    loadInsertables() {
      this.axiosGet('/email_insertables').then(response => {
        this.insertables = response.data.email_insertables;

        // Covers the modal being opened before this request came back.
        this.seedSelections();
      }).catch(() => {
        this.insertables = [];
      })
    }
  },
  mounted() {
    this.loadInsertables();
  }
}

</script>

<style scoped>
  .preview-note {
    font-size: var(--text-xs);
    color: var(--text-muted);
    margin-bottom: var(--space-3);
  }

  .preview-insertables {
    padding: var(--space-3);
    margin-bottom: var(--space-3);

    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    background: var(--surface-alt);
  }

  .preview-insertables-note {
    font-size: var(--text-xs);
    color: var(--text-muted);
    margin-bottom: var(--space-2);
  }

  .preview-field {
    margin-bottom: var(--space-3);
  }

  .preview-label {
    font-size: var(--text-xs);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--text-muted);
    margin-bottom: var(--space-1);
  }

  .preview-subject {
    font-weight: 600;
    padding: var(--space-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    background: var(--surface);
  }

  .preview-body {
    font-family: inherit;
    font-size: var(--text-base);
    white-space: pre-wrap;
    word-break: break-word;

    padding: var(--space-3);
    margin-bottom: 0;
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    background: var(--surface);
  }
</style>
