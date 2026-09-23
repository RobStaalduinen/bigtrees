<template>
  <div class="placeholder-reference">
    <div class="placeholder-reference-header">Placeholders</div>

    <p class="placeholder-reference-intro">
      Copy one and paste it anywhere in the subject or the body, as many times as you like. It is
      replaced with the real value when the email is sent.
    </p>

    <div class="placeholder-group">
      <div class="placeholder-group-title">Built In</div>

      <div v-for="placeholder in predefined" :key="placeholder.key" class="placeholder-row">
        <div class="placeholder-body">
          <code class="placeholder-token">{{ placeholder.token }}</code>
          <div class="placeholder-description" v-if="placeholder.description">
            {{ placeholder.description }}
          </div>
        </div>

        <app-button
          size="sm"
          variant="ghost"
          :icon="iconFor(placeholder)"
          :label="`Copy ${placeholder.token}`"
          :click="() => copy(placeholder)"
        />
      </div>
    </div>

    <div class="placeholder-group">
      <div class="placeholder-group-title">Insertable Content</div>

      <div v-if="insertables.length === 0" class="placeholder-empty">
        No insertable content yet.
      </div>

      <div v-for="placeholder in insertables" :key="placeholder.key" class="placeholder-row">
        <div class="placeholder-body">
          <code class="placeholder-token">{{ placeholder.token }}</code>
          <div class="placeholder-description">{{ placeholder.description }}</div>
          <div class="placeholder-note">
            Body only · {{ placeholder.optionCount }}
            {{ placeholder.optionCount === 1 ? 'option' : 'options' }}
          </div>
        </div>

        <app-button
          size="sm"
          variant="ghost"
          :icon="iconFor(placeholder)"
          :label="`Copy ${placeholder.token}`"
          :click="() => copy(placeholder)"
        />
      </div>
    </div>

    <div class="placeholder-feedback" v-if="copiedToken">{{ copiedToken }} copied</div>
  </div>
</template>

<script>

import { predefinedPlaceholders, insertablePlaceholders } from '@/content/emailPlaceholders';

const COPIED_FEEDBACK_MS = 2000;

export default {
  data() {
    return {
      predefined: [],
      insertables: [],
      copiedToken: null,
      copiedTimeout: null
    }
  },
  methods: {
    iconFor(placeholder) {
      return this.copiedToken === placeholder.token ? 'check2' : 'clipboard';
    },
    copy(placeholder) {
      this.writeToClipboard(placeholder.token).then(() => {
        this.copiedToken = placeholder.token;

        clearTimeout(this.copiedTimeout);
        this.copiedTimeout = setTimeout(() => { this.copiedToken = null }, COPIED_FEEDBACK_MS);
      })
    },
    // The async clipboard API needs a secure context and permission; fall back to a throwaway
    // textarea so the button still works where it is unavailable.
    writeToClipboard(text) {
      if (navigator.clipboard) {
        return navigator.clipboard.writeText(text).catch(() => this.legacyCopy(text));
      }

      return this.legacyCopy(text);
    },
    legacyCopy(text) {
      const field = document.createElement('textarea');
      field.value = text;
      field.setAttribute('readonly', '');
      field.style.position = 'absolute';
      field.style.left = '-9999px';

      document.body.appendChild(field);
      field.select();
      document.execCommand('copy');
      document.body.removeChild(field);

      return Promise.resolve();
    },
    loadPlaceholders() {
      this.axiosGet('/email_insertables').then(response => {
        this.predefined = predefinedPlaceholders(response.data.reserved_keys);
        this.insertables = insertablePlaceholders(response.data.email_insertables);
      }).catch(() => {
        this.predefined = [];
        this.insertables = [];
      })
    }
  },
  mounted() {
    this.loadPlaceholders();
  },
  beforeDestroy() {
    clearTimeout(this.copiedTimeout);
  }
}

</script>

<style scoped>
  .placeholder-reference {
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    background: var(--surface-alt);
    padding: var(--space-3);
  }

  .placeholder-reference-header {
    font-size: var(--text-lg);
    font-weight: 600;
    padding-bottom: var(--space-1);
    border-bottom: 1px solid var(--border-strong);
  }

  .placeholder-reference-intro {
    font-size: var(--text-xs);
    color: var(--text-muted);
    margin: var(--space-2) 0 var(--space-3);
  }

  .placeholder-group {
    margin-bottom: var(--space-3);
  }

  .placeholder-group-title {
    font-size: var(--text-xs);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--text-muted);
    margin-bottom: var(--space-1);
  }

  .placeholder-row {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: var(--space-2);

    padding: var(--space-2) 0;
    border-bottom: 1px solid var(--border);
  }

  .placeholder-row:last-child {
    border-bottom: none;
  }

  .placeholder-body {
    min-width: 0;
  }

  .placeholder-token {
    font-size: var(--text-xs);
    color: var(--main-color);
    word-break: break-all;
  }

  .placeholder-description {
    font-size: var(--text-xs);
    color: var(--text);
  }

  .placeholder-note {
    font-size: var(--text-xs);
    color: var(--text-muted);
    font-style: italic;
  }

  .placeholder-empty {
    font-size: var(--text-xs);
    color: var(--text-muted);
  }

  .placeholder-feedback {
    font-size: var(--text-xs);
    color: var(--success);
    text-align: right;
  }
</style>
