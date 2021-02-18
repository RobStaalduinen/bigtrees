<template>
  <app-right-sidebar :id='id' title='Edit Costs' submitText='Save' :onSubmit='updateCosts' @cancelled='reset'>
    <template v-slot:content>
      <app-multi-costs v-model='costs'></app-multi-costs>
    </template>
  </app-right-sidebar>
</template>

<script>
import SingleCost from '../forms/single';
import EventBus from '@/store/eventBus';
import MultiCostFrom from '@/components/costs/forms/multiple';

export default {
  components: {
    'app-single-cost': SingleCost,
    'app-multi-costs': MultiCostFrom
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
      costs: null
    }
  },
  methods: {
    updateCosts() {
      var params = { costs: this.costs }
      this.axiosPost(`/estimates/${this.estimate.id}/costs/update`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
        this.reset();
      })
    },
    addCost(){
      this.costs.push(this.defaultCost());
    },
    setCost(index, payload) {
        this.costs[index] = { ...payload };
    },
    deleteCost(index) {
      this.costs.splice(index, 1);
    },
    defaultCost() {
      return {
        key: Math.random().toString(36).substr(2, 9),
        amount: null,
        description: null
      }
    },
    reset() {
      this.costs = JSON.parse(JSON.stringify(this.estimate.costs))
    }
  },
  mounted() {
    this.reset();
  }
}
</script>

<style scoped>
  #info-header {
    font-size: 14px;
  }

  .cost-entry {
    border-width: 0 0 1px 0;
    border-color: gray;
    border-style: solid;
  }

  .cost-header {
    display: flex;
    justify-content: space-between;
    margin-top: 8px;
  }

  .delete-icon {
    color: var(--main-color);
  }

  #add-cost-row {
    width: 100%;
    display: flex;
    justify-content: center;
    color: var(--main-color);
    font-size: 18px;
    margin-top: 8px;
    cursor: pointer;
  }

</style>
