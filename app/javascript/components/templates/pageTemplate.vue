<template>
  <div>
    <app-nav></app-nav>
    <b-container id='page-container'>
      <slot></slot>
    </b-container>
  </div>
</template>

<script>
import Nav from '../nav.vue';
import Hours from '../../pages/hours.vue';

export default {
  components:{
    'app-nav': Nav,
    'app-hours': Hours
  }
}
</script>

<style>
  #page-container{
    padding-bottom: 64px;
  }
</style>
