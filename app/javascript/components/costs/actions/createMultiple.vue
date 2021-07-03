<template>
  <app-scrollable-sidebar :id='id' title='Create Costs' submitText='Submit' :onSubmit='createCosts' @cancelled='reset'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-multi-costs
          v-model='costs'
        >
        </app-multi-costs>
      </validation-observer>
    </template>

    <template v-slot:extras>
      <app-quick-costs :addCost='addCost'></app-quick-costs>
    </template>
  </app-scrollable-sidebar>
</template>

<script>
import MultipeCosts from '../forms/multiple';
import EventBus from '@/store/eventBus';
import QuickCosts from '@/components/costs/widgets/quick';

import { setInitialCosts } from '@/components/estimate/utils/stateTransitions';

export default {
  components: {
    'app-multi-costs': MultipeCosts,
    'app-quick-costs': QuickCosts
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
    addCost(amount, description) {
      this.costs.push(
        {
          key: Math.random().toString(36).substr(2, 9),
          amount: amount,
          description: description
        }
      )
    },
    createCosts() {
      this.$refs.observer.validate().then(success => {
        if (!success) {
          return false;
        }
        setInitialCosts(this.estimate, { costs: this.costs }).then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          this.reset();
          EventBus.$emit('ESTIMATE_UPDATED', response.data);
        })
      })
    },
    reset() {
      this.costs = [];
    }
  }
}
</script>

<style scoped>
  #info-header {
    font-size: 14px;
  }
</style>
