<template>
    <app-pane formTitle="Job Site Details">
      <template v-slot:left-side>
        <div>
          <validation-observer ref="observer">
            <app-input-field
              v-model='street'
              name='street'
              label='Street Address'
              validationRules='required'
            />
            <app-input-field
              v-model='city'
              name='city'
              label='City'
              validationRules='required'
            />
          </validation-observer>

          <div>
            <b-form-group v-slot="{ ariaDescribedby }">
              <div class='form-label'>
                Will you allow us to visit the site while you are not present?
              </div>
              <div class='form-subtext'>
                We will call you while we are there to discuss our plans.
              </div>
              <div class='onboarding-form-radios'>
                <b-form-radio v-model="visit_consent" :aria-describedby="ariaDescribedby" name="consent_radios" value=false class='onboarding-form-radio-single'>No</b-form-radio>
                <b-form-radio v-model="visit_consent" :aria-describedby="ariaDescribedby" name="consent_radios" value=true class='onboarding-form-radio-single'>Yes</b-form-radio>
              </div>
            </b-form-group>

            <b-form-group
              label="If you prefer to meet, what days and times typically work for you?"
              label-for="visit-times"
            >
              <b-form-textarea
                id="textarea"
                name='visit-times'
                v-model="visit_times"
                rows="4"
                max-rows="4"
                placeholder="Ex. Mondays after 5pm, weekday afternoons etc, weekends etc."
              ></b-form-textarea>
            </b-form-group>
          </div>
        </div>
      </template>

      <template v-slot:right-side>
        Let's get some details on where the job will take place.
        <br/><br/>
        Please provide the address <b>where the work will be done</b>
        <br/><br/>
        Plus, a few details on how we can access the site, and if we can visit while you are not present.
      </template>

      <template v-slot:controls>
        <app-buttons :nextValidation='validate' :standalone='standalone'></app-buttons>
      </template>
    </app-pane>
</template>

<script>
import Pane from '@/components/onboarding/pane';
import FormButtons from '@/components/onboarding/widgets/formButtons';
import InputField from '@/components/form/inputField';

export default {
  components: {
    'app-pane' : Pane,
    'app-buttons': FormButtons,
    'app-input-field': InputField
  },
  props: ['value', 'standalone'],
  data() {
    return {
      street: this.value.address_attributes.street || "",
      city: this.value.address_attributes.city || "",
      visit_consent: this.value.visit_consent || false,
      visit_times: this.value.visit_times || ""
    }
  },
  computed: {
    site() {
      return {
        address_attributes: {
          street: this.street,
          city: this.city
        },
        visit_consent: this.visit_consent,
        visit_times: this.visit_times
      }
    }
  },
  methods: {
    validate() {
      return this.$refs.observer.validate();
    }
  },
  mounted() {
    this.$emit('input', this.site);
  },
  watch: {
    site() {
      this.$emit('input', this.site)
    }
  }
}
</script>
