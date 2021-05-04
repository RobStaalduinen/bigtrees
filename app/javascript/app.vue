<template>
  <div>
    <router-view v-if='signedIn'></router-view>
  </div>
</template>

<script>
import Nav from './components/nav.vue';
import Hours from './pages/hours.vue';

export default {
  components:{
    'app-nav': Nav,
  },
  data: function () {
    return {
    }
  },
  computed: {
    signedIn() {
      return this.$store.state.user.logged_in;
    }
  },
  mounted() {
    this.$store.dispatch('refreshArborists');
  }
}
</script>

<style scoped>

</style>
