<template>
  <b-modal
    id="error-handler"
    size="lg"
    hide-header
    title="Error"
    @hide="close"
    >
      {{ errorMessage }}
    </b-modal>
</template>

<script>
import EventBus from '@/store/eventBus';
export default {
  props: {

  },
  data() {
    return {
      errorMessage: '',
    }
  },
  methods: {
    close() {
      this.$emit('close');
    },
    formatErrorMessage(error) {
      if (error.response && error.response.data && error.response.data.error) {
        return `There was an error calling ${error.response.config.url}: ${error.response.data.error}`;
      } else if (error.message) {
        return error.message;
      } else {
        return 'An unknown error occurred.';
      }
    }
  },
  mounted() {
    EventBus.$on('API_ERROR', (error) => {
      this.errorMessage = this.formatErrorMessage(error);
      this.$bvModal.show('error-handler');
    });
  },

}
</script>