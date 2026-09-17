<template>
  <div class="email-insertables">
    <div class="email-insertable-group-header">
      <div class="email-insertable-group-title">Insertable Content</div>
      <a class="email-insertable-new" @click="openCreate">New</a>
    </div>

    <p class="email-insertable-description">
      An insertable is a named set of interchangeable paragraphs. Drop its placeholder — for
      example <b>[SCHEDULE_TEXT]</b> — anywhere in a template, and whoever sends that email
      picks one of its options from a dropdown. The chosen text replaces the placeholder;
      choosing nothing leaves the paragraph out altogether.
    </p>

    <div v-if="emailInsertables.length === 0" class="email-insertable-empty">
      No insertable content.
    </div>

    <app-collapsable
      v-for="insertable in emailInsertables"
      :key="insertable.id"
      :id="`email-insertable-${insertable.id}`"
      class="email-insertable"
    >
      <template v-slot:title>
        {{ insertable.label }}
        <span class="email-insertable-key">{{ placeholder(insertable) }}</span>
      </template>

      <template v-slot:content>
        <div v-if="insertable.options.length === 0" class="email-insertable-empty">
          No options.
        </div>

        <div v-for="option in insertable.options" :key="option.id" class="email-insertable-option">
          <div><b>{{ option.label }}</b></div>
          <div class="email-insertable-option-content">{{ option.content }}</div>
        </div>

        <div class='single-estimate-link-row'>
          <div class='single-estimate-link'>
            <b-icon
              icon='pencil-square'
              class='app-icon edit-icon'
              @click="openEdit(insertable)"
            ></b-icon>
          </div>
        </div>
      </template>
    </app-collapsable>

    <app-insertable-manage
      ref='manage'
      id='email-insertable-manage'
      :insertables='emailInsertables'
      :reservedKeys='reservedKeys'
      @changed='retrieveInsertables'
    />
  </div>
</template>

<script>

import InsertableManage from '@/components/emailInsertables/actions/manage';

export default {
  components: {
    'app-insertable-manage': InsertableManage
  },
  data() {
    return {
      emailInsertables: [],
      reservedKeys: []
    }
  },
  methods: {
    retrieveInsertables() {
      this.axiosGet('/email_insertables').then(response => {
        this.emailInsertables = response.data.email_insertables;
        this.reservedKeys = response.data.reserved_keys || [];
      })
    },
    placeholder(insertable) {
      return `[${insertable.key}]`;
    },
    openCreate() {
      this.$refs.manage.open();
    },
    openEdit(insertable) {
      this.$refs.manage.open(insertable);
    }
  },
  mounted() {
    this.retrieveInsertables();
  }

}
</script>

<style scoped>
.email-insertables {
  margin-bottom: var(--space-6);
}

.email-insertable-group-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--space-2);
  padding-bottom: var(--space-1);
  border-bottom: 1px solid var(--border-strong);
}

.email-insertable-group-title {
  font-size: 1.1rem;
  font-weight: 600;
}

.email-insertable-new {
  cursor: pointer;
}

.email-insertable-description {
  font-size: var(--text-sm);
  color: var(--text-muted);
  margin-bottom: var(--space-3);
}

.email-insertable-empty {
  font-size: 0.85rem;
  color: var(--text-muted);
  margin-bottom: var(--space-2);
}

.email-insertable {
  margin-bottom: var(--space-2);
}

.email-insertable-key {
  margin-left: var(--space-2);
  font-size: var(--text-xs);
  color: var(--text-muted);
}

.email-insertable-option {
  padding: var(--space-2) 0;
  border-bottom: 1px solid var(--border);
}

.email-insertable-option-content {
  white-space: pre-line;
}
</style>
