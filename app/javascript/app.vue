<template>
  <div>
    <app-nav></app-nav>
    <b-container>
      <app-hours></app-hours>
    </b-container>
  </div>
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
