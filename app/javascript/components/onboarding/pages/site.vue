<template>
    <app-pane formTitle="Job Site Details">
      <template v-slot:left-side>
        <div>
          <app-input-field
            v-model='street'
            name='street'
            label='Street Address'
          />
          <app-input-field
            v-model='city'
            name='city'
            label='City'
          />

          <div>
            <b-form-group v-slot="{ ariaDescribedby }">
              <div class='form-label'>
                Do you want the wood removed after the job?
              </div>
              <div class='onboarding-form-radios'>
                <b-form-radio v-model="wood_removal" :aria-describedby="ariaDescribedby" name="removal_radios" value=false class='onboarding-form-radio-single'>No</b-form-radio>
                <b-form-radio v-model="wood_removal" :aria-describedby="ariaDescribedby" name="removal_radios" value=true class='onboarding-form-radio-single'>Yes</b-form-radio>
              </div>
            </b-form-group>

            <b-form-group v-slot="{ ariaDescribedby }">
              <div class='form-label'>
                Are there any breakables near any of your trees or stumps?
              </div>
              <div class='onboarding-form-radios'>
                <b-form-radio v-model="breakables" :aria-describedby="ariaDescribedby" name="breakables_radios" value=false class='onboarding-form-radio-single'>No</b-form-radio>
                <b-form-radio v-model="breakables" :aria-describedby="ariaDescribedby" name="breakables_radios" value=true class='onboarding-form-radio-single'>Yes</b-form-radio>
              </div>
            </b-form-group>

            <b-form-group v-slot="{ ariaDescribedby }">
              <div class='form-label'>
                At any point, is the access width to your trees or stumps less than 36 inches?
              </div>
              <div class='onboarding-form-radios'>
                <b-form-radio v-model="low_access_width" :aria-describedby="ariaDescribedby" name="access_radios" value=false class='onboarding-form-radio-single'>No</b-form-radio>
                <b-form-radio v-model="low_access_width" :aria-describedby="ariaDescribedby" name="access_radios" value=true class='onboarding-form-radio-single'>Yes</b-form-radio>
              </div>
            </b-form-group>
          </div>
        </div>
      </template>

      <template v-slot:right-side>
        Let's get some details on where the job will take place.
        <br/><br/>
        An address, plus a few details on about your site will help us plan for your job.
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
      street: this.value.street || "",
      city: this.value.city || "",
      wood_removal: this.value.wood_removal || true,
      breakables: this.value.breakables || false,
      low_access_width: this.value.low_access_width || false
    }
  },
  computed: {
    site() {
      return {
        street: this.street,
        city: this.city,
        wood_removal: this.wood_removal,
        breakables: this.breakables,
        low_access_width: this.low_access_width
      }
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
