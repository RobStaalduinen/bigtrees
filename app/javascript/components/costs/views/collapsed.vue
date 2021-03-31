<template>
  <div>
    <app-collapsable id='costs-collapse'>
      <template v-slot:title>
        <b>Costs</b> &nbsp; - Total: {{ estimate.total_cost_with_tax | currency }}
      </template>

      <template v-slot:content>
        <b-row class='spaced-row cost-row' v-for='(cost, index) in estimate.costs' :key='index'>
          <b-col cols='9'>
            {{ cost.description }}
          </b-col>
          <b-col cols='3'>
            {{ cost.amount | currency }}
          </b-col>
        </b-row>

        <b-row class='spaced-row cost-row'>
          <b-col cols='9' class='right-column'>
            <i>Subtotal</i>
          </b-col>
          <b-col cols='3'>
            {{ estimate.total_cost | currency }}
          </b-col>
        </b-row>

        <b-row class='spaced-row cost-row'>
          <b-col cols='9' class='right-column'>
            <b>Total</b>
          </b-col>
          <b-col cols='3'>
            {{ estimate.total_cost_with_tax | currency }}
          </b-col>
        </b-row>

        <div class='single-estimate-link-row'>
          <div class='single-estimate-link' v-b-toggle.edit-costs>
            <b-icon icon='pencil-square' class='app-icon'></b-icon>
          </div>
        </div>
      </template>
    </app-collapsable>

    <app-edit-costs :estimate='estimate' id='edit-costs'></app-edit-costs>
  </div>
</template>

<script>
import EditCosts from '../actions/edit'

export default {
  components: {
    'app-edit-costs': EditCosts
  },
  props: {
    estimate: {
      required: true
    }
  },
  methods: {

  }
}
</script>

<style scoped>
  .cost-row {
    font-size: 14px;
  }
</style>
