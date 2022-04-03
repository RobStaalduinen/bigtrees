<template>
    <app-pane>
      <template v-slot:left-side>
        It couldn't be simpler
      </template>
      <template v-slot:right-side>
        <div id='right-side'>
          How many trees or stumps need work?

          <br>

          <b-form-group label="Quantity" v-slot="{ ariaDescribedby }">
            <b-form-radio v-model="amount" :aria-describedby="ariaDescribedby" name="some-radios" value=1>One</b-form-radio>
            <b-form-radio v-model="amount" :aria-describedby="ariaDescribedby" name="some-radios" value=2>Two</b-form-radio>
            <b-form-radio v-model="amount" :aria-describedby="ariaDescribedby" name="some-radios" value=3>Three</b-form-radio>
          </b-form-group>
        </div>
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
  data() {
    return {
      amount: this.value
    }
  },
  watch: {
    amount() {
      this.$emit('input', this.amount);
    }
  }
}
</script>

<style scoped>

</style>
