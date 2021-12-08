<template>
  <div>
    <router-view v-if='signedIn'></router-view>
    <app-notificaiton-box></app-notificaiton-box>
  </div>
</template>

<script>
import Nav from './components/nav.vue';
import Hours from './pages/hours.vue';
import NotificationBox from '@/components/ui/notificationBox';

export default {
  components:{
    'app-nav': Nav,
    'app-notificaiton-box': NotificationBox
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
