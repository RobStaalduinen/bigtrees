<template>
    <app-right-sidebar :id='id' title='Reject Receipt' submitText='Submit' :onSubmit='rejectReceipt' @cancelled='reset'>
      <template v-slot:content>
        <validation-observer ref="observer">
          <app-input-field
            v-model='rejectionReason'
            name="rejection_reason"
            label='Rejection Reason'
            validationRules='required'
          ></app-input-field>
        </validation-observer>
      </template>
  </app-right-sidebar>
</template>

<script>
import FileUpload from '@/components/file/actions/upload';
import EventBus from '@/store/eventBus';
import moment from 'moment';

export default {
  props: ['id', 'receipt'],
  data() {
    return {
      rejectionReason: null,
    }
  },
  methods: {
    rejectReceipt() {
      this.errorMessage = null;
      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }

        let params = { receipt: {
          rejection_reason: this.rejectionReason,
          state: 'rejected'
        }}

        this.axiosPut(`/receipts/${this.receipt.id}`, params).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('RECEIPT_UPDATED');
          setTimeout(() => {
            this.reset();
          }, 500);
        })
      })
    },
    reset() {
      this.rejectionReason = null;
    }
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
