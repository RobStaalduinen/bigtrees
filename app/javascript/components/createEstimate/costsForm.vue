<template>
  <div id='cost-list-container'>

    <div class='single-cost' v-for='index in costs.length' :key='index - 1'>
      <cost-list-single-cost 
        v-model='costs[index -1]'
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
      costs: [{}]
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
    },
    handleDelete(index) {
      this.costs.splice(index, 1);
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
