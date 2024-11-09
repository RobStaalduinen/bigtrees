<template>
    <app-pane formTitle="Let's get started">
      <template v-slot:left-side>
        <div id='right-side'>
          <b-form-group v-slot="{ ariaDescribedby }">
            <div class='form-label'>
              What type of quote are you looking for? <br>
              All options are free.
            </div>

          </b-form-group>

          <div class='quote-option' @click='() => chooseOption("quote")'>
            <div class='quote-option-left'>
              Simple Tree Removal, Trimming, Stump Removal or Fertilizer Injections <br/>

              <span class='quote-highlight'>RECEIVE A QUOTE TODAY</span>
            </div>
            <div class='quote-option-right'>
              <b-icon class='quote-next' icon="chevron-right"></b-icon>
            </div>
          </div>

          <div class='quote-option' @click='() => chooseOption("visit")'>
            <div class='quote-option-left'>
              Full Property Quote and Recommendations <br/>

              <span class='quote-highlight'>SCHEDULE A SITE VISIT</span>
            </div>
            <div class='quote-option-right'>
              <b-icon class='quote-next' icon="chevron-right"></b-icon>
            </div>
          </div>

          <div class='quote-option' @click='() => chooseOption("contact")'>
            <div class='quote-option-left'>
              Commercial Quote  <br/>

              <span class='quote-highlight'>LET'S TALK</span>
            </div>
            <div class='quote-option-right'>
              <b-icon class='quote-next' icon="chevron-right"></b-icon>
            </div>
          </div>
        </div>
      </template>

      <template v-slot:right-side>
        It couldn't be simpler to get an estimate. Just a few simple questions about your job, and we'll take care of the rest.

        <br /><br />

        Let's start with the number of trees or stumps you need work on.

        <br /><br />

        If your job requires more than three trees or stumps, please contact us directly so we can set up a more detailed consultation.
      </template>

    </app-pane>
</template>

<script>
import Pane from '@/components/onboarding/pane';

export default {
  components: {
    'app-pane' : Pane
  },
  props: {
    value: {
      type: String
    },
    stumpingOnly: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    chooseOption(option) {
      console.log("EMIT");
      this.$emit('input', option);
    }
  }
}
</script>

<style>
  .quote-option {
    width: 100%;
    margin-bottom: 8px;
    border-width: 0 0 1px 0;
    border-color: var(--main-color);
    border-style: solid;
    padding: 8px;

    display: flex;

    cursor: pointer;
  }

  .quote-option-left {
    width: 90%;
  }

  .quote-option-right {
    width: 10%;
    display: flex;
    flex-direction: column;
    justify-content: center;

    border-width: 0 0 0 1px;
    border-style: solid;
    border-color: lightgrey;
    padding-left: 8px;
  }

  .quote-next {
    font-size: 24px;
    color: var(--main-color);
  }

  .quote-highlight {
    font-weight: 600;
    color: var(--main-color);
  }
</style>
