<template>
  <app-right-sidebar :id='id' title='Create Costs' submitText='Submit' :onSubmit='createCosts'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-multi-costs
          v-model='costs'
        >
        </app-multi-costs>
      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import MultipeCosts from '../forms/multiple';

import { setInitialCosts } from '@/components/estimate/utils/stateTransitions';

export default {
  components: {
    'app-multi-costs': MultipeCosts
  },
  props: {
    id: {
      required: true
    },
    estimate: {
      required: true
    }
  },
  data() {
    return {
      costs: []
    }
  },
  methods: {
    createCosts() {
      this.$refs.observer.validate().then(success => {
        if (!success) {
          return false;
        }
        setInitialCosts(this.estimate, { costs: this.costs }).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          this.reset();
          this.$emit('changed', response.data.estimate);
        })
      })

      // var params = { cost: this.cost }
      // this.axiosPost(`/estimates/${this.estimate.id}/costs`, params).then(response => {
      //   this.$root.$emit('bv::toggle::collapse', this.id);
      //   this.$emit('changed', response.data.estimate);
      // })
    },
    reset() {
      this.costs = [];
    }
  },
  watch: {
    costs() {
      console.log(this.costs);
    }
  }
}
</script>

<style scoped>
  #info-header {
    font-size: 14px;
  }
</style>
