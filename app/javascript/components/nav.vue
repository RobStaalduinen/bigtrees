<template>
  <div>
    <b-navbar toggleable="true" class='nav' id='app-nav'>
      <div id='navbar-fixed'>
        <div id='navbar-fixed-top'>
          <b-navbar-brand href="#" id='logo'><img id='logo-image' v-bind:src="organizationLogo()"></b-navbar-brand>
          <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>
        </div>
        <!-- <div id='navbar-fixed-bottom' v-if='hasMultipleCompanies()'>
          <span>Current Company: {{ organizationName() }} <a @click='changeOrganization' id='change-org-button'>(Change)</a></span>
        </div> -->
      </div>

      <b-collapse id="nav-collapse" is-nav>
        <b-dropdown-item to="/admin/estimates" v-if='hasPermission("estimates", "list")'>Quotes</b-dropdown-item>
        <b-dropdown-item to="/admin/estimates/new" v-if='permissions.canUpdate("estimates")'>Create Quote</b-dropdown-item>
        <b-dropdown-item to='/admin/customers' v-if='permissions.canList("customers")'>Customers</b-dropdown-item>
        <b-dropdown-item to="/admin/receipts" v-if='permissions.canList("receipts")'>Receipts</b-dropdown-item>
        <b-dropdown-item to="/admin/equipment" v-if='permissions.canList("equipment_requests")'>Repair Requests</b-dropdown-item>
        <b-dropdown-item to='/admin/hours' v-if='permissions.canList("hours")'>Hours</b-dropdown-item>
        <b-dropdown-item to='/admin/company' v-if='permissions.canAdmin("organizations")'>My Company</b-dropdown-item>
        <b-nav-item-dropdown class='interior-dropdown' text="My Details" toggle-class="text-dark">
            <b-dropdown-item :to="profileLink" v-if='permissions.canShow("arborists")'>Profile</b-dropdown-item>
            <b-dropdown-item v-if="hasMultipleCompanies()" @click='changeOrganization'>Change Company</b-dropdown-item>
            <b-dropdown-item @click='logout'>Log Out</b-dropdown-item>
          </b-nav-item-dropdown>
      </b-collapse>

    </b-navbar>
    <b-modal id='organization-modal' title='Change Organization' ok-title="Cancel" ok-only>
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
    }
  },
  methods: {
    changeOrganization() {
      this.$bvModal.show('organization-modal')
    },
    logout() {
      this.axiosGet('/logout').then(response => {
        window.location.href='/login'
      })
    },
    organizationName() {
      if(this.$store.state.organization != null) {
        return this.$store.state.organization.name;
      }
    },
    organizationLogo() {
      let organization = this.$store.state.organization;
      if(organization != null) {
        return organization.condensed_logo_url || organization.logo_url;
      }
    },
    hasMultipleCompanies() {
      return this.$store.state.user.organization_count > 1
    }
  }
}
</script>

<style scoped>
  #app-nav{
    border-width: 0 0 3px 0;
    border-color: var(--main-color);
    border-style: solid;
  }

  #logo-image {
    max-width: 250px;
    max-height: 70px;
  }

  .text-dark {
    color: black;
  }

  #navbar-fixed {
    width: 100%;
    font-size: 14px;
  }

  #navbar-fixed-top {
    display: flex;
    justify-content: space-between;
  }

  #navbar-fixed-bottom {
    display: flex;
    justify-content: center;
    margin-top: -16px;
  }

  #change-org-button {
    font-size: 12px;
  }


  @media (min-width: 200px) and (max-width: 759px){
    .navbar {
      padding: 0 8px;
    }

    .interior-dropdown {
      padding-top: 8px;
      padding-bottom: 8px;
      padding-left: 16px;
    }
  }

  @media (min-width: 760px){
    .navbar {
      padding: 0 0 0 32px;
    }

    .interior-dropdown {
      padding-top: 16px;
      padding-bottom: 16px;
      padding-left: 8px;
    }
  }
</style>
