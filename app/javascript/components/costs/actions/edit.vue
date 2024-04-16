<template>
  <app-scrollable-sidebar :id='id' title='Edit Costs' submitText='Save' :onSubmit='updateCosts' @cancelled='reset'>
    <template v-slot:content>
      <div id='edit-cost-box'>
        <app-multi-costs v-model='costs'></app-multi-costs>
      </div>
    </template>

    <template v-slot:extras>
      <app-quick-costs :addCost='addCost'></app-quick-costs>
    </template>
  </app-scrollable-sidebar>
</template>

<script>
import SingleCost from '../forms/single';
import EventBus from '@/store/eventBus';
import MultiCostFrom from '@/components/costs/forms/multipleExpanded';
import QuickCosts from '@/components/costs/widgets/quick';

export default {
  components: {
    'app-single-cost': SingleCost,
    'app-multi-costs': MultiCostFrom,
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
    addCost(amount, description) {

      this.costs.push(
        {
          key: Math.random().toString(36).substr(2, 9),
          amount: amount,
          description: description
        }
      )
    },
    reset() {
      this.costs = JSON.parse(JSON.stringify(this.estimate.costs))
    }
  },
  mounted() {
    this.reset();
  },
  watch: {
    estimate() {
      this.costs = JSON.parse(JSON.stringify(this.estimate.costs))
    }
  }
}
</script>

<style scoped>
  #info-header {
    font-size: 14px;
  }

  #edit-cost-box {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding-bottom: 24px;
  }

  #cost-select {
    max-height: 80%;
    overflow: scroll;
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
