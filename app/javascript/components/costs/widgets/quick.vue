<template>
  <div id='quick-costs-box'>
    <div><b>Quick Costs</b></div>
    <div id='quick-cost-actions'>
      <b-button
        v-for="(cost, index) in quick_costs"
        :key="index"
        class='cost-button'
        size="sm"
        @click='addCost(cost.default_cost, cost.content)'
      >
        {{ cost.label }}
      </b-button>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    addCost: {
      type: Function,
      required: true
    }
  },
  data() {
    return {
      quick_costs: [],
      organization_id: this.$store.state.organization.id
    }
  },
  methods: {
    retrieveCosts() {
      this.axiosGet(`/organizations/${this.organization_id}/quick_costs`).then(response => {
        console.log("Quick costs", response.data.quick_costs);
        this.quick_costs = response.data.quick_costs;
      })
    },
  },
  mounted() {
    this.retrieveCosts();
  }
}
</script>

<style scoped>
  #quick-costs-box {
    display: flex;
    flex-direction: column;
    padding: 8px;
  }

  #quick-cost-actions {
    display: flex;
    flex-wrap: wrap;
  }

  .cost-button {
    margin-right: 8px;
    margin-bottom: 8px;

    padding: 4px 6px;
  }
</style>
