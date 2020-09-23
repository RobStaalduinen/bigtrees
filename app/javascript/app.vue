<template>
  <router-view></router-view>
</template>

<script>
import Nav from './components/nav.vue';
import Hours from './pages/hours.vue';

export default {
  components:{
    'app-nav': Nav,
    'app-hours': Hours
  },
  data: function () {
    return {
    }
  }
}
</script>

<style scoped>
  
</style>
