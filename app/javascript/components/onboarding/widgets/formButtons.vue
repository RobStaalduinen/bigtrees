<template>
  <div id='form-buttons'>
    <button @click='back' v-if='displayBack'>
      Back
    </button>
    <button @click='forward' v-if='displayForward'>
      Forward
    </button>
  </div>

</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  props: {
    displayBack: {
      required: false,
      default: true
    },
    displayForward: {
      required: false,
      default: true
    }
  },
  methods: {
    back() {
      EventBus.$emit('form-back');
    },
    forward() {
      EventBus.$emit('form-forward');
    }
  },
}
</script>

<style>

</style>
