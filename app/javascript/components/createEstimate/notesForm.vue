<template>
  <div>
    <div v-for='(note, index) in notes' :key='note.key' class='note-block'>
      <div class='note-header'>
        Note #{{ index + 1 }}
        <b-icon icon='trash-fill' class='delete-icon' @click='deleteNote(index)'/>
      </div>
      <app-single-note
        :value='note'
        @input='(payload) => updateNote(index, payload)'
      ></app-single-note>
    </div>

    <a id='add-note-button' @click.prevent='addNote'>
      + Add Note +
    </a>
  </div>
</template>

<script>
import SingleNote from '@/components/notes/forms/single'

export default {
  components: {
    'app-single-note': SingleNote
  },
  props: {
    value: {
      type: Array,
      default: () => { return [] }
    }
  },
  data() {
    return {
      // Stable per-note key so v-for rows survive deletes (index keys would
      // reassign the wrong note's state to a reused component).
      notes: (this.value || []).map(note => ({ key: this.makeKey(), ...note }))
    }
  },
  methods: {
    makeKey() {
      return Math.random().toString(36).substr(2, 9)
    },
    defaultNote() {
      return {
        key: this.makeKey(),
        content: null,
        fileUrl: null
      }
    },
    addNote() {
      this.notes.push(this.defaultNote())
      this.emit()
    },
    deleteNote(index) {
      this.notes.splice(index, 1)
      this.emit()
    },
    // app-single-note emits a fresh note object (without our key) — re-attach
    // the row's key so its identity is preserved.
    updateNote(index, payload) {
      this.$set(this.notes, index, { key: this.notes[index].key, ...payload })
      this.emit()
    },
    emit() {
      this.$emit('input', this.notes)
    }
  }
}
</script>

<style scoped>
  .note-block {
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid lightgray;
  }

  .note-header {
    display: flex;
    justify-content: space-between;
    font-size: 14px;
    color: var(--main-color);
    margin-bottom: 8px;
  }

  .delete-icon {
    cursor: pointer;
  }

  #add-note-button {
    width: 100%;
    display: flex;
    justify-content: center;
    color: var(--main-color);
    cursor: pointer;
  }
</style>
