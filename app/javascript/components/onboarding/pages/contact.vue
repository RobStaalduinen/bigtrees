<template>
    <app-pane formTitle='Your Details'>
      <template v-slot:left-side>
        <div v-if='subtype=="commercial_quote"' class='subtext'>
          A commercial quote will be no problem! Please leave your contact details, and we will be in touch to discuss the details.
        </div>
        <div>
          <validation-observer ref="observer">
            <app-input-field
              v-model='name'
              name='name'
              label='Your name'
              validationRules='required'
            />
            <app-input-field
              v-model='email'
              name='email'
              label='Email Address'
              validationRules='required'
            />
            <app-input-field
              v-model='phone'
              name='phone'
              label='Phone Number'
            />
          </validation-observer>
        </div>
      </template>

      <template v-slot:right-side>
        Just let us know how to reach you, and we'll be in touch as soon as we can. <br/><br />
        We'll never share your information with anyone else, and we'll only use it to contact you about your estimate.
      </template>

      <template v-slot:controls>
        <app-buttons :nextValidation='validate' :loadingState='true' forwardText='Submit'></app-buttons>
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
  props: ['value', 'subtype'],
  data() {
    return {
      name: this.value.name,
      email: this.value.email,
      phone: this.value.phone
    }
  },
  computed: {
    customer() {
      return {
        name: this.name,
        email: this.email,
        phone: this.phone
      }
    }
  },
  methods: {
    validate() {
      return this.$refs.observer.validate();
    }
  },
  watch: {
    customer() {
      this.$emit('input', this.customer)
    }
  }
}
</script>

<style scoped>
  .subtext {
    font-size: 0.9em;
    color: #666;
    margin-bottom: 1em;
  }
</style>
