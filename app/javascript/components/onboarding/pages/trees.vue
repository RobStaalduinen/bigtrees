<template>
    <app-pane>
      <template v-slot:left-side>
        We need some info
      </template>
      <template v-slot:right-side>
        Tell us about Tree #{{treeNumber}}
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
  },
  props: ['treeNumber']
}
</script>
