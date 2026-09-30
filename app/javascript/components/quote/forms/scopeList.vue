<template>
  <div class='scope-list'>
    <div class='scope-list-label'>{{ label }}</div>

    <div v-if='rows.length === 0' class='scope-list-empty'>
      Nothing added yet.
    </div>

    <div v-for='(row, index) in rows' :key='row.key' class='scope-row'>
      <span class='scope-bullet'>&bull;</span>
      <b-form-input
        v-model='row.text'
        :placeholder='placeholder'
        class='scope-input'
        autocomplete='off'
        @keydown.enter.prevent='addAfter(index)'
      ></b-form-input>
      <b-icon
        icon='trash'
        class='app-icon edit-icon scope-remove'
        :aria-label='`Remove item ${index + 1}`'
        @click='remove(index)'
      ></b-icon>
    </div>

    <div class='scope-add' @click='add'>
      <b-icon icon='plus-circle' class='app-icon'></b-icon>
      <span class='scope-add-label'>{{ addLabel }}</span>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    label: {
      type: String,
      required: true
    },
    addLabel: {
      type: String,
      default: 'Add an item'
    },
    placeholder: {
      type: String,
      default: ''
    },
    // [{ key, text }] — the key keeps inputs from being reused across removals
    value: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      rows: this.value
    }
  },
  methods: {
    add() {
      this.rows.push(this.blankRow());
      this.$emit('input', this.rows);
    },
    // Enter mid-list inserts below that row rather than jumping to the end.
    addAfter(index) {
      this.rows.splice(index + 1, 0, this.blankRow());
      this.$emit('input', this.rows);
    },
    remove(index) {
      this.rows.splice(index, 1);
      this.$emit('input', this.rows);
    },
    blankRow() {
      return { key: Math.random().toString(36).substr(2, 9), text: '' };
    }
  },
  watch: {
    value() {
      this.rows = this.value;
    },
    rows: {
      deep: true,
      handler() {
        this.$emit('input', this.rows);
      }
    }
  }
}
</script>

<style scoped>
  .scope-list {
    margin-bottom: 20px;
  }

  .scope-list-label {
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 6px;
  }

  .scope-list-empty {
    font-size: 12px;
    color: gray;
    margin-bottom: 6px;
  }

  .scope-row {
    display: flex;
    align-items: center;
    margin-bottom: 6px;
  }

  .scope-bullet {
    color: var(--main-color);
    margin-right: 6px;
    font-size: 18px;
    line-height: 1;
  }

  .scope-input {
    flex: 1;
  }

  .scope-remove {
    margin-left: 8px;
    flex-shrink: 0;
  }

  .scope-add {
    display: flex;
    align-items: center;
    cursor: pointer;
    font-size: 13px;
    color: var(--main-color);
    margin-top: 4px;
  }

  .scope-add-label {
    margin-left: 6px;
  }
</style>
