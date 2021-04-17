<template>
    <app-right-sidebar :id='id' title='Update Document' submitText='Submit' :onSubmit='updateDocument' @completed='reset'>
      <template v-slot:content>
        <app-input-field
          v-model='name'
          name="name"
          label='Name'
          validationRules='required'
        ></app-input-field>

        <div>
          <label class='d-block'>File</label>
          <app-file-upload
            v-model='documentUrl'
            accept=".jpg, .jpeg, .png, .pdf, .doc, .docx"
          ></app-file-upload>
        </div>

        <div style='margin-top: 16px;'>
          <label class='d-block'>Expiry Date</label>
          <b-form-datepicker
            v-model='expires_at'
            :date-format-options="{ year: 'numeric', month: 'numeric', day: 'numeric' }"
            locale='en-CA'
          >
          </b-form-datepicker>
        </div>

        <div class='error-box' v-if='errorMessage'>
          {{ errorMessage }}
        </div>
      </template>
  </app-right-sidebar>
</template>

<script>
import FileUpload from '@/components/file/actions/upload';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-file-upload': FileUpload
  },
  props: ['id', 'arborist_id', 'document'],
  data() {
    return {
      name: null,
      documentUrl: null,
      expires_at: null,
      errorMessage: null
    }
  },
  methods: {
    updateDocument() {
      this.errorMessage = null;
      if (this.name == null || this.documentUrl == null) {
        this.errorMessage = 'Please make sure name is filled out and file has finished uploading'
        EventBus.$emit('FORM_VALIDATION_FAILED');
        return
      }

      const updateFunction = this.isCreateAction() ? this.axiosPost : this.axiosPut
      const baseUrl = `/arborists/${this.arborist_id}`
      const updateUrl = this.isCreateAction() ? '/documents' : `/documents/${this.document.id}`

      let params = { name: this.name, url: this.documentUrl, expires_at: this.expires_at }

      updateFunction(baseUrl + updateUrl, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('DOCUMENT_UPDATED', response.data.document);
      })
    },
    isCreateAction() {
      return this.document == null
    },
    reset() {
      // this.document = null
    },
    setInitial() {
      if(this.document == null) {
        this.name = null;
        this.documentUrl = null;
        this.expires_at = null;
        return
      }
      this.name = this.document.name;
      this.documentUrl = this.document.file_url;
      this.expires_at = this.document.expires_at;
    }
  },
  watch: {
    document() {
      this.setInitial();
    }
  },
  mounted() {
    this.setInitial();
  }
}
</script>

<style scoped>
  #form-container {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    height: 100%;
  }

  #delete-button {
    margin-top: 64px;
    padding: 2px;
  }
</style>
