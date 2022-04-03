<template>
  <div id='form-buttons'>
    <button @click='back'>
      Back
    </button>
    <button @click='forward'>
      Forward
    </button>
  </div>

</template>

<script>
import EventBus from '@/store/eventBus';

export default {
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
