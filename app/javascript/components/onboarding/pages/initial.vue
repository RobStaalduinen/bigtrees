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
        We have several options to get you started.
        <br><br>
        You can <b>Receive a quote today</b> if you upload a few images and some basic information about your job.
        <br><br>
        If you prefer, we can <b>Schedule a site visit</b> so we can inspect your property and make our recommendations on the best way forward.

        <br /><br />

        If you are seeing a <b>Commercial Quote</b>, we are more than happy to discuss it and tailor our services to your needs.
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
      this.$emit('input', option);
    }
  },
  mounted() {
    console.log("Resetting");
    this.$emit('input', null);
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
