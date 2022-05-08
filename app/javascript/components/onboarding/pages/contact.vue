<template>
    <app-pane rightTitle='Your Details'>
      <template v-slot:left-side>
        Let us know how we can get in touch with you. <br /><br />
        We will make sure to get back to you as soon as possible.
      </template>
      <template v-slot:right-side>
        <div>
          <app-input-field
            v-model='name'
            name='name'
            label='Your name'
          />
          <app-input-field
            v-model='email'
            name='email'
            label='Email Address'
          />
          <app-input-field
            v-model='phone'
            name='phone'
            label='Phone Number'
          />
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
import InputField from '@/components/form/inputField';

export default {
  components: {
    'app-pane' : Pane,
    'app-buttons': FormButtons,
    'app-input-field': InputField
  },
  props: ['value'],
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
        email: this.emaik,
        phone: this.phone
      }
    }
  },
  watch: {
    customer() {
      this.$emit('input', this.customer)
    }
  }
}
</script>
