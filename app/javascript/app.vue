<template>
  <div>
    <app-update-banner></app-update-banner>
    <router-view v-if='signedIn'></router-view>
    <app-image-gallery v-if='signedIn'></app-image-gallery>
    <app-notificaiton-box></app-notificaiton-box>
    <app-error-handler></app-error-handler>
  </div>
</template>

<script>
import Nav from './components/nav.vue';
import Hours from './pages/hours.vue';
import NotificationBox from '@/components/ui/notificationBox';
import ErrorHandler from './components/common/utils/errorHandler.vue';
import ImageGallery from '@/components/tree_images/views/imageGallery';

export default {
  components:{
    'app-nav': Nav,
    'app-notificaiton-box': NotificationBox,
    'app-error-handler': ErrorHandler,
    'app-image-gallery': ImageGallery
  },
  data: function () {
    return {
    }
  },
  computed: {
    signedIn() {
      return this.$store.state.user.logged_in && this.$store.state.organization.id != null;
    }
  },
  mounted() {
    this.$store.dispatch('refreshArborists');
  }
}
</script>

<style scoped>

</style>
