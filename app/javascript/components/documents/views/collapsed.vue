<template>
  <div>
    <app-collapsable id='costs-collapse'>
      <template v-slot:title>
        <b>Documents ({{ documents != null ? documents.length : '' }})</b>
      </template>

      <template v-slot:content>
        <div v-for='(document, index) in documents' :key='document.id' class='single-document'>

          <div class='single-document-left'>
            <div class='single-document-title'>{{ document.name }}</div>
            <div class='single-documents-expiry'>Expires at: {{ expiryString(document) }}</div>
          </div>

          <div class='single-document-right'>
            <b-icon icon='pencil-square' class='app-icon edit-icon' id='document-edit-icon' @click='toggleUpdate(index)' />
          </div>

        </div>

        <div class='single-estimate-link-row'>
          <div class='single-estimate-link' @click='toggleUpdate'>
            Add New
          </div>
        </div>
      </template>
    </app-collapsable>

    <app-update-document id='update-document' :document='selectedDocument'></app-update-document>
  </div>
</template>

<script>
import moment from 'moment';
import UpdateDocument from '@/components/documents/actions/update';

export default {
  components: {
    'app-update-document': UpdateDocument
  },
  props: ['documents'],
  data() {
    return {
      selectedDocument: null
    }
  },
  methods: {
    expiryString(document) {
      if(document.expires_at == null) {
        return 'Not Set';
      }
      return this.formatDate(document.expires_at)
    },
    formatDate(date) {
      return moment(date).format('YYYY-MM-DD')
    },
    toggleUpdate(index = null) {
      if(index == null) {
        this.selectedDocument = null;
      }
      else {
        this.selectedDocument = this.documents[index];
      }
      this.$root.$emit('bv::toggle::collapse', 'update-document');
    }
  }
}
</script>

<style scoped>
  .single-document {
    font-size: 14px;
    padding: 8px 0;

    border-style: solid;
    border-color: lightgray;
    border-width: 0 0 1px 0;

    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .single-document-title {
    font-weight: 600;
  }

  .single-documents-expiry {
    margin-top: 8px;
  }

  #document-edit-icon {
    font-size: 18px;
    margin-left: 16px;
  }
</style>
