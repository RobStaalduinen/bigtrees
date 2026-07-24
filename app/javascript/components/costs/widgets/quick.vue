<template>
  <div id='quick-costs-box'>
    <div class='quick-costs-label'>Quick Costs</div>
    <div id='quick-cost-actions'>
      <app-button
        v-for="(cost, index) in quick_costs"
        :key="index"
        variant='outline'
        size='md'
        icon='plus'
        :text='cost.label'
        :click='() => addCost(cost.default_cost, cost.content)'
      ></app-button>
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
    gap: var(--space-2);
    padding: var(--space-3) var(--space-2);
  }

  .quick-costs-label {
    font-size: var(--text-xs);
    font-weight: 600;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    color: var(--text-muted);
  }

  /* Uniform gap in both axes keeps the wrapped grid evenly spaced and the
     larger tap targets (md app-buttons) easier to hit. */
  #quick-cost-actions {
    display: flex;
    flex-wrap: wrap;
    gap: var(--space-2);
  }
</style>
