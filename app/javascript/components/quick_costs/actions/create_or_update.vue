<template>
  <app-right-sidebar :id='id' title='Create Quick Cost Buton' submitText='Submit' :onSubmit='submitCost'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-input-field
          v-model='labelValue'
          name='label'
          label='Label'
          validationRules='required'
        />

        <app-input-field
          v-model='contentValue'
          name='content'
          label='Content'
          validationRules='required'
        />

        <app-number-field
          v-model='defaultCost'
          name='default_cost'
          label='Default Cost'
          validationRules='required'
        />
      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>

import EventBus from '@/store/eventBus';

export default {
  components: {

  },
  props: {
    id: {
      required: true
    },
    organization_id: {
      required: true
    },
    quick_cost_id: {
      required: false
    }
  },
  data() {
    return {
      labelValue: null,
      contentValue: null,
      defaultCost: 0.0
    }
  },
  methods: {
    submitCost(){
      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }

        if (success) {
          let params = {
            quick_cost: {
              label: this.labelValue,
              content: this.contentValue,
              default_cost: this.defaultCost
            }
          }
          this.axiosPost(`/organizations/${this.organization_id}/quick_costs`, params).then(response => {
            this.$root.$emit('bv::toggle::collapse', this.id);
            this.reset();
            this.$emit('changed', response.data.quick_cost);
          })
        }
      })
    },
    reset(){
      this.labelValue = null;
      this.contentValue = null;
      this.defaultCost = 0.0;
    }
  }
}
</script>
