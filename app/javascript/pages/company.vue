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
      <app-company-settings v-if='selectedOption === "Settings"'></app-company-settings>
      <app-outgoing-email v-if='selectedOption === "Outgoing Email"'></app-outgoing-email>
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
import Settings from '../components/company/views/settings.vue';
import OutgoingEmail from '../components/company/views/outgoing_email.vue';

export default {
  components: {
    'app-employees': Employees,
    'app-vehicles': Vehicles,
    'app-information': Information,
    'app-quick-costs': QuickCosts,
    'app-email-templates': EmailTemplates,
    'app-manage-tags': ManageTags,
    'app-company-settings': Settings,
    'app-outgoing-email': OutgoingEmail
  },
  data() {
    return {
      selectedOption: 'Information',
      organization: this.$store.state.organization
    }
  },
  mounted() {
    // Check URL for 'section' query parameter
    const urlParams = new URLSearchParams(window.location.search);
    const sectionParam = urlParams.get('section')?.split('_')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ');

    // If section parameter exists and is in our options list, select it
    if (sectionParam && this.options.includes(sectionParam)) {
      this.selectedOption = sectionParam;
    } else {
      this.selectedOption = 'Information'; // Default selection
    }
  },
  computed: {
    options() {
      let baseOptions = ['Information', 'Employees', 'Equipment', 'Quick Costs', 'Email Templates', 'Tags', 'Settings'];
      if (this.organization.configuration && this.organization.configuration.outgoing_email) {
        baseOptions.push('Outgoing Email');
      }

      return baseOptions
    }
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
