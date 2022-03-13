<template>
  <div>
    <app-pane>
      <template v-slot:left-side>
        This is a test left
      </template>
      <template v-slot:right-side>
        This is a test right
      </template>
    </app-pane>
  </div>
</template>

<script>
import Pane from './components/onboarding/pane';

export default {
  components: {
    'app-pane': Pane
  },
  data() {
    return {
      context: null
    }
  },
  mounted() {
    if (window.location.href.includes('requests')) {
      this.context = 'Requests'
    }
  }
}
</script>
