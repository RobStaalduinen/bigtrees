<template>
  <div id='quick-costs-box'>
    <div><b>Quick Costs</b></div>
    <div id='quick-cost-actions'>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Tree Removal")'>Tree</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Stump Removal")'>Stump</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Site Cleanup")'>Cleanup</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Log Disposal")'>Logs</b-button>
      <b-button class='cost-button' size="sm" @click='addCost(0, "Chips/Mulch Disposal")'>Mulch</b-button>
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
