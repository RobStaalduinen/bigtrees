<template>
    <app-pane formTitle='Contact Us'>
      <template v-slot:left-side>
        <div>
          Contact Us
        </div>
      </template>

      <template v-slot:right-side>
        Almost there, just one more step remaining. <br /><br />
        Just let us know how to reach you, and we'll be in touch with your estimate as soon as we can. <br/><br />
        We'll never share your information with anyone else, and we'll only use it to contact you about your estimate.
      </template>

      <template v-slot:controls>
        <app-buttons :displayForward='false' :standalone='standalone'></app-buttons>
      </template>
    </app-pane>
</template>

<script>
import Pane from '@/components/onboarding/pane';
import FormButtons from '@/components/onboarding/widgets/formButtons';

export default {
  components: {
    'app-pane' : Pane,
    'app-buttons': FormButtons,
  },
  props: ['standalone'],
}
</script>
