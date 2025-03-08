<template>
  <div>
    <app-collapsable id='tools-collapse'>
      <template v-slot:title>
        <b>Equipment Requirements - {{ amountMessage() }}</b>
      </template>

      <template v-slot:content>
        <ul id='tool-selection-container'>
          <li v-for='tool in estimate.vehicles' :key='tool.id'>
            {{ tool.name }}
          </li>
        </ul>

        <div class='single-estimate-link-row' v-if="hasPermission('estimates', 'update')">
          <div class='single-estimate-link' v-b-toggle.edit-requirements>
            <b-icon icon='pencil-square' class='app-icon'></b-icon>
          </div>
        </div>
      </template>
    </app-collapsable>

    <app-edit-requirements :estimate='estimate' id='edit-requirements'></app-edit-requirements>
  </div>
</template>

<script>
import EditRequirements from '../actions/edit'

export default {
  components: {
    'app-edit-requirements': EditRequirements
  },
  props: {
    estimate: {
      required: true
    }
  },
  methods: {
    amountMessage() {
      return this.estimate.vehicles.length < 1 ? 'None selected' : `${this.estimate.vehicles.length} selected`
    }
  },
  mounted() {

  }
}
</script>

<style scoped>
  .cost-row {
    font-size: 14px;
  }

  #tool-selection-container {
    margin-top: 8px;
  }

  #tool-selection-container > li {
    margin-bottom: 4px;
  }
</style>
