<template>
    <app-pane>
      <template v-slot:left-side>
        Tell us about where the work will be done
      </template>
      <template v-slot:right-side>
        Some questions about the site, access etc.
      </template>
      <template v-slot:controls>
        <app-buttons></app-buttons>
      </template>
    </app-pane>
</template>

<script>
import Pane from '@/components/onboarding/pane';
import FormButtons from '@/components/onboarding/widgets/formButtons';

export default {
  components: {
    'app-pane' : Pane,
    'app-buttons': FormButtons
  }
}
</script>
