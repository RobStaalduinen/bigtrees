<template>
  <div>
    <app-collapsable id='notes-collapse'>
      <template v-slot:title>
        <b>Notes ({{ `${estimate.notes.length} added` }})</b>
      </template>

      <template v-slot:content>
        <div v-for='note in estimate.notes' :key='note.id' class='note-row'>
          <img v-if='note.image' :src='note.image.image_url' class='note-image' />
          <div v-else class='note-image'>

          </div>

          <div class='note-content'>
            <div class='note-header'><b>{{ `${note.author_name} | ${formatDate(note.created_at)}`}}</b></div>
            {{ note.content.trim() }}
          </div>
        </div>

        <div class='single-estimate-link-row'>
          <!-- <div class='single-estimate-link' v-b-toggle.edit-costs> -->
          <div class='single-estimate-link' v-b-toggle.create-note>
            Add New
          </div>
        </div>
      </template>
    </app-collapsable>

    <app-create-note :estimate='estimate' id='create-note'></app-create-note>

    <b-modal :id='`note-modal`' centered title='Note Details'>
      <div class='modal-internal' v-if='displayedNote'>
        <div>
          {{ `${displayedNote.author_name} | ${formatDate(displayedNote.created_at)}`}}
        </div>

        <img :src='displayedNote.image.image_url' class='modal-image'/>

        <div class='modal-text-content'>
          {{ displayedNote.content }}
        </div>
      </div>

      <template v-slot:modal-footer>
        <b-button
          class='submit-button'
          @click='close()'
        >Done</b-button>
      </template>
    </b-modal>
  </div>
</template>

<script>

import CreateNote from '../actions/create'
import moment from 'moment';

export default {
  components: {
    'app-create-note': CreateNote
  },
  props: {
    estimate: {
      required: true
    }
  },
  data() {
    return {
      displayedNote: null
    }
  },
  methods: {
    toggleModal(note_id) {
      this.displayedNote = this.estimate.notes.filter(note => note.id == note_id)[0];
      this.$bvModal.show(`note-modal`);
    },
    close() {
      this.$bvModal.hide(`note-modal`);
    },
    formatDate(inputDate) {
      return moment(inputDate).format('MMM Do')
    }
  },
  mounted() {

  }
}
</script>

<style scoped>
  .note-row {
    display: flex;
    padding: 8px;

    border: 1px solid lightgray;
    margin: 4px 0;
    cursor: pointer;
  }

  .note-row:nth-child(even) {
    background-color: #f8f7f7;
  }

  .note-image {
    min-width: 20%;
    max-width: 20%;
    margin-right: 8px;
  }

  .note-header {
    margin-bottom: 4px;
  }

  .note-content {
    display: flex;
    flex-direction: column;
    font-size: 14px;
    white-space: pre-line;
  }

  .modal-image {
    width: 100%;
  }

  .modal-text-content {
    margin-top: 8px;
  }
</style>
