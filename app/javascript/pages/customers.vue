<template>
  <page-template>
    <app-header title='Customers'></app-header>

    <app-customer-list></app-customer-list>

  </page-template>
</template>

<script>
import CustomerList from '../components/customers/customerList'; 

export default {
  components: {
    'appCustomerList': CustomerList
  },
  data() {
    return {
    }
  },
}
</script>

<style scoped>
  
</style>
