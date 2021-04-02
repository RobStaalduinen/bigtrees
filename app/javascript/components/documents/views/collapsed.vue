<template>
  <div>
    <app-collapsable id='costs-collapse'>
      <template v-slot:title>
        <b>Documents ({{ documents != null ? documents.length : '' }})</b>
      </template>

      <template v-slot:content>
        <div v-for='(document, index) in documents' :key='document.id' class='single-document'>

          <div class='single-document-left'>
            <div class='single-document-title' @click='togglePreview(index)'>{{ document.name }}</div>
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

    <app-update-document
      id='update-document'
      :document='selectedDocument'
      :arborist_id='arborist_id'
    ></app-update-document>

    <b-modal
      :title='selectedDocumentName'
      id='preview-modal'
      size="xl"
    >
      <app-pdf :src='selectedDocument.file_url' v-if='selectedDocument && selectedDocumentType() == "pdf"'></app-pdf>
      <img
        style='max-width: 100%;'
        :src='selectedDocument.file_url'
        v-if='selectedDocument && selectedDocumentType() != "pdf"'
      />

      <template v-slot:modal-footer>
        <div style='display: flex; justify-content: space-between; width: 100%;'>
          <b-button
            type='submit'
            class='inverse-button modal-button'
            @click='deleteDocument'
          >
            Delete Document
          </b-button>
          <b-button class='main-color-button modal-button' @click='closePreview()'>Done</b-button>
        </div>
      </template>
    </b-modal>
  </div>
</template>

<script>
import moment from 'moment';
import UpdateDocument from '@/components/documents/actions/update';
import pdf from 'vue-pdf'
import { fileExtensionFromPath } from '@/utils/fileUtils';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-update-document': UpdateDocument,
    'app-pdf': pdf
  },
  props: ['documents', 'arborist_id'],
  data() {
    return {
      selectedDocument: null
    }
  },
  computed: {
    selectedDocumentName() {
      if(this.selectedDocument == null) {
        return '';
      }
      return this.selectedDocument.name;
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
    selectedDocumentType(){
      if(this.selectedDocument == null) {
        return '';
      }
      return fileExtensionFromPath(this.selectedDocument.file_url)
    },
    toggleUpdate(index = null) {
      this.selectedDocument = index == null ? null : this.documents[index];
      this.$root.$emit('bv::toggle::collapse', 'update-document');
    },
    togglePreview(index) {
      this.selectedDocument = this.documents[index];
      this.$bvModal.show('preview-modal');
    },
    closePreview(){
      this.selectedDocument = null;
      this.$bvModal.hide('preview-modal');
    },
    deleteDocument() {
      let confirmed = confirm("Are you sure you want to permanently delete this document?");

      if(!confirmed) { return }

      this.axiosDelete(`/arborists/${this.arborist_id}/documents/${this.selectedDocument.id}`).then(response => {
        this.$bvModal.hide('preview-modal');
        EventBus.$emit('DOCUMENT_UPDATED', {})
      })
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
    color: var(--main-color);
    cursor: pointer;
  }

  .single-documents-expiry {
    margin-top: 8px;
  }

  #document-edit-icon {
    font-size: 18px;
    margin-left: 16px;
  }

  .modal-button {
    width: 48%;
  }
</style>
