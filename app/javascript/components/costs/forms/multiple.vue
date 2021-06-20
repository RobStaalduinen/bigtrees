<template>
  <div>
    <i id='info-header'>Use negative numbers for discounts</i>
    <div v-for='(cost, index) in costs' :key='cost.key' class='cost-entry'>
      <div class='cost-header'>
        Cost #{{ (parseInt(index) + 1) }}
        <b-icon icon='trash-fill' class='delete-icon' v-if='canDeleteCosts()' @click='deleteCost(index)'/>
      </div>
      <app-single-cost
        :value='cost'
        :baseName='`cost_${index}`'
        @input='(payload) => setCost(index, payload)'>
      </app-single-cost>
    </div>

    <div id='add-cost-row' @click.prevent='addCost'>
      <span>+ Add Cost +</span>
    </div>
  </div>
</template>

<script>
import SingleCost from '../forms/single';

export default {
  components: {
    'app-single-cost': SingleCost
  },
  props: {
    value: {
      required: false,
      default: () => [this.defaultCost()]
    }
  },
  data() {
    return {
      costs: null
    }
  },
  methods: {
    addCost(){
      this.costs.push(this.defaultCost());
    },
    setCost(index, payload) {
      this.costs[index] = { ...payload };
      this.$emit('input', this.costs);
    },
    deleteCost(index) {
      this.costs.splice(index, 1);
      this.$emit('input', this.costs);

    },
    canDeleteCosts() {
      return this.costs.length > 1;
    },
    defaultCost() {
      return {
        key: Math.random().toString(36).substr(2, 9),
        amount: null,
        description: null
      }
    },
    reset() {
      if(this.value == null || this.value.length === 0){
        this.costs = [this.defaultCost()];
      }
      else {
        this.costs = this.value.map((cost) => {
          cost.key = Math.random().toString(36).substr(2, 9);
          return cost;
        } );
      }
    }
  },
  mounted() {
    this.reset();
  },
  watch: {
    value() {
      this.costs = this.value;
      console.log(this.costs);
    }
  }
}
</script>

<style scoped>
  #info-header {
    font-size: 14px;
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
