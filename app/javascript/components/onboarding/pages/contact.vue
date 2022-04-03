<template>
    <app-pane>
      <template v-slot:left-side>
        We'll be in touch as soon as possible.
      </template>
      <template v-slot:right-side>
        How can we contact you?
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
