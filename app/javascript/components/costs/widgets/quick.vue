<template>
  <div id='quick-costs-box'>
    <div><b>Quick Costs</b></div>
    <div id='quick-cost-actions'>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Tree Cut Down")'>Removal</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Grind stump (6\" depth) and any visible surface roots")'>Stump</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Site Cleanup - Branches Disposed, Rake Lawn, Street/Driveway Swept")'>Cleanup</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, `Disposal of Log/Trunk Wood over 6" diameter`)'>Logs</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Stump Grindings and Root Debris Disposal")'>Grindings</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Tree Trim")'>Trim</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Arborist Report (City Fees and Replanting Costs extra if necessary)")'>Report</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Dispose of all Gutter Debris and test for proper flow")'>Gutter</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Deep Root Fertilizer Injections")'>Inject</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Spruce Tree Fungicide Spray for Rhizosphaera Needlecast Prevention")'>Spray</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "General tidy and cleanup of the garden beds (pruning, weeding and mulch incl.)")'>Garden</b-button>
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
