<template>
    <app-pane rightTitle="Let's get started">
      <template v-slot:left-side>
        It couldn't be simpler
      </template>

      <template v-slot:right-side>
        <div id='right-side'>
          <b-form-group v-slot="{ ariaDescribedby }">
            <div class='form-label'>
              How many trees or stumps need work?
            </div>

            <b-form-radio v-model="amount" :aria-describedby="ariaDescribedby" name="some-radios" value=1 class='quantity-radio'>One</b-form-radio>
            <b-form-radio v-model="amount" :aria-describedby="ariaDescribedby" name="some-radios" value=2 class='quantity-radio'>Two</b-form-radio>
            <b-form-radio v-model="amount" :aria-describedby="ariaDescribedby" name="some-radios" value=3 class='quantity-radio'>Three</b-form-radio>
          </b-form-group>
        </div>
      </template>

      <template v-slot:controls>
        <app-buttons :displayBack='false'></app-buttons>
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
  props: ['value'],
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

<style>
.quantity-radio {
  margin-bottom: 8px;

  border: 1px solid var(--main-color);
  border-radius: 5px;
  display: flex;
  align-items: center;
}

.quantity-radio:hover {
  background-color: #efefef;
}

.quantity-radio > label{
  width: 100%;
  margin-bottom: 0;
  padding: 4px;
  padding-left: 12px;
}

.quantity-radio > input {
  margin: 0;
  margin-left: 8px
}

input[type='radio']:checked:after {
  width: 15px;
  height: 15px;
  border-radius: 15px;
  top: -2px;
  left: -1px;
  position: relative;
  background-color: var(--main-color);
  content: '';
  display: inline-block;
  visibility: visible;
  border: 2px solid white;

  padding: 4px;
}
</style>
