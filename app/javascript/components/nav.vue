<template>
  <div>
    <b-navbar toggleable="true" class='nav' id='app-nav'>
      <b-navbar-brand href="#" id='logo'><img id='logo-image' v-bind:src="require('images/BigTreeServicesLogo.png')"></b-navbar-brand>
      <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>

      <b-collapse id="nav-collapse" is-nav>
        <b-dropdown-item to="/admin/estimates" v-if='canManageEstimates'>Quotes</b-dropdown-item>
        <b-dropdown-item to="/admin/estimates/new" v-if='canManageEstimates'>Create Quote</b-dropdown-item>
        <b-dropdown-item href="/vehicles" v-if='admin'>Vehicles</b-dropdown-item>
        <b-dropdown-item href="/arborists" v-if='admin'>Arborists</b-dropdown-item>
        <b-dropdown-item to='/admin/customers' v-if='admin'>Customers</b-dropdown-item>
        <b-dropdown-item href="/payouts" v-if='admin'>Payouts</b-dropdown-item>
        <b-dropdown-item href="/receipts">Receipts</b-dropdown-item>
        <b-dropdown-item href="/equipment_requests" v-if='admin'>Repair Requests</b-dropdown-item>
        <b-dropdown-item href="/equipment_requests/new" v-if='!admin'>Create Repair Request</b-dropdown-item>
        <b-dropdown-item to='/admin/hours'>Hours</b-dropdown-item>
        <b-dropdown-item v-bind:href="profileLink">Profile</b-dropdown-item>
      </b-collapse>
    </b-navbar>
  </div>
</template>

<script>
export default {
  computed: {
    admin() {
      return this.$store.state.user.admin;
    },
    canManageEstimates(){
      return this.admin || this.$store.state.user.can_manage_estimates;
    },
    userId() {
      return this.$store.state.user.user_id;
    },
    profileLink() {
      return `/arborists/${this.userId}`;
    }
  },
  mounted() {
    console.log(this.$store.state.user);
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
