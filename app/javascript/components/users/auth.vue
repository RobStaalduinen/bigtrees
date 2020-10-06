<template>
  
</template>

<script>
  export default {
    mounted() {
      this.axiosGet('/authenticate').then(response => {
        if(response.status == 200 && response.data.logged_in){
          console.log(response.data);
          this.$store.commit('setUser', response.data);
        }
        else{
          window.location.href = '/login'
        }
          
      })
    }
  }
</script>
