<template>
  <div>
    <app-auth></app-auth>
    <router-view v-if='signedIn'></router-view>
  </div>
</template>

<script>
import Nav from './components/nav.vue';
import Hours from './pages/hours.vue';
import Auth from './components/users/auth';

export default {
  components:{
    'app-nav': Nav,
    'app-auth': Auth
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
