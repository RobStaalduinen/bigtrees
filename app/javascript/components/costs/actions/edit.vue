<template>
  <app-right-sidebar :id='id' title='Edit Costs' submitText='Save' :onSubmit='updateCosts' @completed='reset'>
    <template v-slot:content>
      <i id='info-header'>Use negative numbers for discounts</i>
      <div v-for='(cost, index) in costs' :key='cost.id' class='cost-entry'>
        <div class='cost-header'>
          Cost #{{ (parseInt(index) + 1) }}
          <b-icon icon='trash-fill' class='delete-icon' @click='deleteCost(index)'/>
        </div>
        <app-single-cost
          :value='cost'
          @input='(payload) => setCost(index, payload)'>
        </app-single-cost>
      </div>
    </template>
  </app-right-sidebar>
</template>

<script>
import SingleCost from '../forms/single';

export default {
  components: {
    'app-single-cost': SingleCost
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
        this.$emit('changed', response.data.estimate);
      })
    },
    setCost(index, payload) {
        this.costs[index] = { ...payload };
    },
    deleteCost(index) {
      this.costs.splice(index, 1);
    },
    reset() {
      this.costs =  JSON.parse(JSON.stringify(this.estimate.costs))
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
</style>
