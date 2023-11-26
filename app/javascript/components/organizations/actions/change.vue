<template>
  <app-select-field
    label='Choose the organization to view'
    v-model='selectedOrganization'
    name='selectedOrganization'
    :options="organizationOptions"
  />
</template>

<script>
import EventBus from '@/store/eventBus'

export default {
  components: {
  },
  props: {
  },
  data() {
    return {
      organizations: [],
      selectedOrganization: null
    }
  },
  methods: {
    populateOrganizations() {
      this.axiosGet('/organizations').then(response => {
        this.organizations = response.data.organizations;
        this.setInitialOrganization();
      })
    },
    setInitialOrganization() {
      let initialId = localStorage.getItem("selectedOrganizationId")
      if(initialId != null) {
        let foundOrg = this.organizations.find(org => org.id == initialId);
        if(foundOrg != null) {
          this.selectedOrganization = foundOrg;
        }
      }
    }
  },
  mounted() {
    this.populateOrganizations();
  },
  computed: {
    organizationOptions() {
      return this.organizations.map(org => {
        return { value: org, text: org.name }
      });

    }
  },
  watch: {
    selectedOrganization() {
      if(this.selectedOrganization != null && this.selectedOrganization.id != localStorage.getItem('selectedOrganizationId')) {
        localStorage.setItem("selectedOrganizationId", this.selectedOrganization.id);
        localStorage.setItem("selectedOrganizationName", this.selectedOrganization.name);

        location.reload();
      }
    }
  }
}
</script>

<style scoped>
  .form-box {
    margin-bottom: 16px;
  }
</style>
