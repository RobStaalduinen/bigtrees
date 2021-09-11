<template>
  <div>
    <app-single-note
      v-for='(note, index) in notes'
      :key='index'
      v-model='notes[index]'
    ></app-single-note>

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
      notes: this.value
    }
  },
  methods: {
    defaultNote() {
      return {
        content: null,
        fileUrl: null
      }
    },
    addNote() {
      this.notes.push(this.defaultNote())
    }
  },
  watch: {
    notes() {
      this.$emit('input', this.notes)
    }
  }
}
</script>

<style scoped>
  #add-note-button {
    width: 100%;
    display: flex;
    justify-content: center;
    color: var(--main-color);
    cursor: pointer;
  }
</style>
