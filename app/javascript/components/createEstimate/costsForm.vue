<template>
  <div id='cost-list-container'>

    <div class='single-cost' v-for='index in costs.length' :key='version + "_" + (index - 1)'>
      <cost-list-single-cost 
        v-model='costs[index-1]'
        @deleted='handleDelete'
        :index='index-1'
        :displayDelete='displayDelete'
      >
      </cost-list-single-cost>
      <hr>
    </div>

    <a id='add-cost-button' @click.prevent='addCost'>
      + Add Cost +
    </a>
    
  </div>  
</template>

<script>
import SingleCost from './singleCost';

export default {
  components: {
    'cost-list-single-cost': SingleCost
  },
  data() {
    return {
      costs: [{}],
      version: 0
    }
  },
  computed: {
    displayDelete() {
      return this.costs.length > 1;
    }
  },
  methods: {
    addCost() {
      this.costs.push({})
      this.version += 1;
    },
    handleDelete(index) {
      console.log(`DELETING INDEX AT ${index}`)
      this.costs.splice(index, 1);
      this.version += 1;
      console.log(this.costs);
    }
  },
  watch: {
    costs: function(){
      this.$emit('input', this.costs)
    }
  }
}
</script>

<style scoped>
  #cost-list-container {
    display: flex;
    flex-direction: column;
  }

  #add-cost-button {
    width: 100%;
    display: flex;
    justify-content: center;
    color: var(--main-color);
  }
</style>
