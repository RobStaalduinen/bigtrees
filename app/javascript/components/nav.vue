<template>
  <div>
    <b-navbar toggleable="lg" class='nav' id='app-nav'>
      <b-navbar-brand href="#" id='logo'><img id='logo-image' v-bind:src="require('images/BigTreeServicesLogo.png')"></b-navbar-brand>
      <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>

      <b-collapse id="nav-collapse" is-nav>
        <b-dropdown-item href="/estimates">Quotes</b-dropdown-item>
        <b-dropdown-item href="/vehicles">Vehicles</b-dropdown-item>
        <b-dropdown-item href="/arborists">Arborists</b-dropdown-item>
        <b-dropdown-item to='/admin/customers'>Customers</b-dropdown-item>
        <b-dropdown-item href="/payouts">Payouts</b-dropdown-item>
        <b-dropdown-item href="/receipts">Receipts</b-dropdown-item>
        <b-dropdown-item href="/equipment_requests">Repair Requests</b-dropdown-item>
        <b-dropdown-item to='/admin/hours'>Hours</b-dropdown-item>
        <b-dropdown-item v-bind:href="profileLink">Profile</b-dropdown-item>
      </b-collapse>
    </b-navbar>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      profileLink: `/arborists/${userId}`
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
      padding: 8px;
    }
  }

  @media (min-width: 760px){
    .navbar {
      padding: 0 0 0 32px;
    }
  }
</style>
