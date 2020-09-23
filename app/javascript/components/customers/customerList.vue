<template>
  <div>
    <app-search-field v-model='searchTerm'></app-search-field>
    <app-pagination 
      v-model='currentPage'
      :totalRows='totalCustomers'
    >
    </app-pagination>

    <hr>

    <div class='list-container' v-if='customers != null'>
      <div id='loading-overlay' v-if='loadingCustomers'>
        <app-loader></app-loader>
      </div>
      <app-single-customer v-for="customer in customers" :key='customer.id' :customer='customer'></app-single-customer>
    </div>
  </div>
</template>

<script>
import SingleCustomer from './singleCustomer';

export default {
  components:{
    'appSingleCustomer': SingleCustomer
  },
  data(){
    return{
      loadingCustomers: true,
      customers: null,
      totalCustomers: 0,
      searchTerm: null,
      currentPage: 1
    }
  },
  methods: {
    retrieveCustomers() {
      this.loadingCustomers = true;
      var params = { q: this.searchTerm, page: this.currentPage }
      this.axiosGet('/customers.json', params)
          .then(response => {
            this.customers = response.data['customers'];
            this.totalCustomers = response.data['total_entries'];
            this.loadingCustomers = false;
          })
    }
  },
  mounted() {
    this.retrieveCustomers();
  },
  watch: {
    searchTerm: function(){
      this.retrieveCustomers();
    },
    currentPage: function(){
      this.retrieveCustomers();
    }
  }
}
</script>

<style scoped>
  .list-container{
    display: flex;
    flex-direction: column;
    position: relative;
  }

  .pagination-control {
    width: 100%;
  }
  
  #loading-overlay{
    z-index: 10;
    display: block;
    position: absolute;
    height: 100%;
    top: 0;
    left: 0;
    right: 0;
    background: rgba(0, 0, 0, 0.1);
  }

</style>
