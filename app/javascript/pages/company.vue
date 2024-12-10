<template>
  <page-template>
    <!-- <app-header title='My Company' /> -->
    <div id='company-page-control'>
        <app-select-field
          label='My Company Settings'
          v-model='selectedOption'
          name='selected_option'
          :options="options"
          validationRules='required'
        />
    </div>

    <div id='company-page-content'>
      <app-information v-if='selectedOption === "Information"'></app-information>
      <app-employees v-if='selectedOption === "Employees"'></app-employees>
      <app-vehicles v-if='selectedOption === "Equipment"'></app-vehicles>
    </div>
  </page-template>
</template>

<script>

import Information from '../components/company/views/information.vue';
import Employees from '../pages/employees.vue';
import Vehicles from '../pages/vehicles.vue';

export default {
  components: {
    'app-employees': Employees,
    'app-vehicles': Vehicles,
    'app-information': Information
  },
  data() {
    return {
      selectedOption: 'Information',
      options: ['Information', 'Employees', 'Equipment']
    }
  },
  mounted() {

  },
  methods: {

  }
}
</script>

<style scoped>
  #company-page-control {
    padding: 8px;
    border-width: 0 0 2px 0;
    border-style: solid;
    border-color: grey;

  }
</style>
