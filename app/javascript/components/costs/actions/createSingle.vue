<template>
  <app-right-sidebar :id='id' title='Create Cost/Discount' submitText='Submit' :onSubmit='createCost' @completed='reset'>
    <template v-slot:content>
        <i id='info-header'>Use negative numbers for discounts</i>
        <app-single-cost
          v-model='cost'
        >
        </app-single-cost>
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
      cost: { amount: null, description: null}
    }
  },
  methods: {
    createCost() {
      var params = { cost: this.cost }
      this.axiosPost(`/estimates/${this.estimate.id}/costs/create_single`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        this.$emit('changed', response.data.estimate);
      })
    },
    reset() {
      this.cost = { amount: null, description: null};
    }
  }
}
</script>

<style scoped>
  #info-header {
    font-size: 14px;
  }
</style>
