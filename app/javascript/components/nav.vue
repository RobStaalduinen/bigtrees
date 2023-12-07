<template>
  <div>
    <b-navbar toggleable="true" class='nav' id='app-nav'>
      <b-navbar-brand href="#" id='logo'><img id='logo-image' v-bind:src="require('images/BigTreeServicesLogo.png')"></b-navbar-brand>
      <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>

      <b-collapse id="nav-collapse" is-nav>
        <b-dropdown-item to="/admin/estimates" v-if='hasPermission("estimates", "list")'>Quotes</b-dropdown-item>
        <b-dropdown-item to="/admin/estimates/new" v-if='permissions.canUpdate("estimates")'>Create Quote</b-dropdown-item>
        <b-dropdown-item to="/admin/vehicles" v-if='permissions.canAdmin("vehicles")'>Vehicles</b-dropdown-item>
        <b-dropdown-item to="/admin/employees" v-if='permissions.canAdmin("arborists")'>Employees</b-dropdown-item>
        <b-dropdown-item to='/admin/customers' v-if='permissions.canList("customers")'>Customers</b-dropdown-item>
        <b-dropdown-item to="/admin/receipts" v-if='permissions.canList("receipts")'>Receipts</b-dropdown-item>
        <b-dropdown-item to="/admin/equipment" v-if='permissions.canList("equipment_requests")'>Repair Requests</b-dropdown-item>
        <b-dropdown-item to='/admin/hours' v-if='permissions.canList("hours")'>Hours</b-dropdown-item>
        <b-dropdown-item @click='changeOrganization' v-if='permissions.canAdmin("organizations")'>Change Organization</b-dropdown-item>
        <b-dropdown-item :to="profileLink" v-if='permissions.canShow("arborists")'>Profile</b-dropdown-item>
      </b-collapse>
    </b-navbar>
    <b-modal id='organization-modal' v-if='permissions.canAdmin("organizations")' title='Change Organization' ok-title="Cancel" ok-only>
      <app-change-organization></app-change-organization>
    </b-modal>
  </div>
</template>

<script>
import ChangeOrganization from '@/components/organizations/actions/change.vue'

export default {
  components: {
    'app-change-organization': ChangeOrganization
  },
  computed: {
    userId() {
      return this.$store.state.user.user_id;
    },
    profileLink() {
      return `/admin/users/${this.userId}`;
    },
    permissions() {
      return this.$store.state.authorization;
    },
  },
  methods: {
    changeOrganization() {
      this.$bvModal.show('organization-modal')
    },
    organizationChanged() {
      console.log("Done");
    }
  }
}
</script>

<style scoped>
  #app-nav{
    border-width: 0 0 3px 0;
    border-color: red;
    border-style: solid;
  }

  #logo-image {
    max-width: 250px;
  }

  @media (min-width: 200px) and (max-width: 759px){
    .navbar {
      padding: 0 8px;
    }
  }

  @media (min-width: 760px){
    .navbar {
      padding: 0 0 0 32px;
    }
  }
</style>
