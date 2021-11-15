<template>
    <app-right-sidebar :id='id' title='Create Note' submitText='Submit' :onSubmit='createNote' @cancelled='reset'>
      <template v-slot:content>
        <validation-observer ref="observer">

          <app-note-form v-model='note'></app-note-form>

          <div class='error-box' v-if='errorMessage'>
            {{ errorMessage }}
          </div>
        </validation-observer>
      </template>
  </app-right-sidebar>
</template>

<script>
// import FileUpload from '@/components/file/actions/upload';
import EventBus from '@/store/eventBus';
import NoteForm from '../forms/single';
// import moment from 'moment';

// import { stringOptionList, objectOptionList } from '@/utils/formUtils';

export default {
  props: ['id', 'estimate'],
  components: {
    'app-note-form': NoteForm
  },
  data() {
    return {
      note: {},
      errorMessage: ''
    }
  },

  methods: {
    createNote() {
      this.errorMessage = null;
      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }

        // if(!this.uploading && !this.image_url) {
        //   this.errorMessage = 'Please upload an image of the receipt';
        //   EventBus.$emit('FORM_VALIDATION_FAILED');
        //   return
        // }

        if(this.note.uploading && !this.note.fileUrl) {
          this.errorMessage = 'Please wait for upload to finish before submitting';
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return
        }

        let params = { note: {
          content: this.note.content,
        }}

        if(this.note.fileUrl != null) {
          params.note.image_attributes = {
            image_url: this.note.fileUrl
          }
        }

        this.axiosPost(`/estimates/${this.estimate.id}/notes`, params).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('ESTIMATE_UPDATED', response.data);
          setTimeout(() => {
            this.reset();
          }, 500);
        })
      })
    },
    reset() {
      this.note = null;
    },
    // handleUploadStatus(uploadStatus) {
    //   this.uploading = uploadStatus;
    // }
  },
  mounted() {

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
</style>
