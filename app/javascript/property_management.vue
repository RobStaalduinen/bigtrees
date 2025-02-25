<template>
  <div id="property-management-container">
    <div id="property-management-header">
      <div id='title'>
        <div class='container'>
          Issue Submission

          <div id='subtitle'>Welcome to the Issue Submission Portal for {{ customerName }}</div>
        </div>
      </div>
      
    </div>
    <div class="container">
      <app-create-property-management-request :customer_shortname="customerShortname" />
    </div>
  </div>

</template>

<script>
import CreatePropertyManagementRequest from '@/components/property_management/actions/create';

export default {
  components: {
    'app-create-property-management-request': CreatePropertyManagementRequest
  },
  data() {
    return {
      customerShortname: document.getElementById('property-management-container').getAttribute('data-customer-shortname'),
      customerName: document.getElementById('property-management-container').getAttribute('data-customer-name')
    }
  }
}

</script>

<style>

  #title {
    font-size: 1.2em;
    font-weight: bold;

    background-color: var(--main-color);
    color: white;
  }

  #subtitle {
    font-size: 0.8em;
    font-weight: normal;
    margin-top: 8px;
  }
</style>