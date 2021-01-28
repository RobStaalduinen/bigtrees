<template>
  <b-button
    type='submit'
    block
    :class='buttonClass'
    @click='onClick'
    v-if='!submitting'
    >
      {{ label }}
    </b-button>
    <div v-else>
      <b-spinner id='submit-button-loader'></b-spinner>
    </div>
</template>

<script>
import EventBus from '@/store/eventBus'

export default {
  props: {
    label: {
      type: String,
      required: true
    },
    onSubmit: {
      type: Function,
      required: false,
      default: null
    },
    buttonClass: {
      required: false,
      type: String,
      default: 'submit-button'
    }
  },
  data() {
    return {
      submitting: false
    }
  },
  methods: {
    onClick() {
      this.submitting = true;
      if(this.onSubmit != null) {
        var validationPassed = this.onSubmit();

        if(validationPassed === false) {
          this.submitting = false
        }
      }
    }
  },
  mounted() {
    EventBus.$on('FORM_VALIDATION_FAILED', () => {
      this.submitting = false;
    });
  }
}
</script>

<style>
  #submit-button-loader {
    color: var(--main-color);
  }
</style>
