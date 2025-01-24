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
      <app-quick-costs v-if='selectedOption === "Quick Costs"' :organization_id="organization.id"></app-quick-costs>
      <app-email-templates v-if='selectedOption === "Email Templates"'></app-email-templates>
      <app-manage-tags v-if='selectedOption === "Tags"' :organization_id="organization.id"></app-manage-tags>
    </div>
  </page-template>
</template>

<script>

import Information from '../components/company/views/information.vue';
import Employees from '../pages/employees.vue';
import Vehicles from '../pages/vehicles.vue';
import QuickCosts from '../components/quick_costs/views/list.vue';
import EmailTemplates from '../components/emailTemplates/views/list.vue';
import ManageTags from '../components/tags/views/manage.vue';

export default {
  components: {
    'app-employees': Employees,
    'app-vehicles': Vehicles,
    'app-information': Information,
    'app-quick-costs': QuickCosts,
    'app-email-templates': EmailTemplates,
    'app-manage-tags': ManageTags
  },
  data() {
    return {
      selectedOption: 'Information',
      options: ['Information', 'Employees', 'Equipment', 'Quick Costs', 'Email Templates', 'Tags'],
      organization: this.$store.state.organization
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
