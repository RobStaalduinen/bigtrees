/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import Vue from 'vue'
import { BootstrapVue, IconsPlugin } from 'bootstrap-vue'
Vue.use(BootstrapVue)
Vue.use(IconsPlugin)
Vue.use(require('vue-moment'));

import App from '../app.vue'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'
import '../stylesheets/variables'
import '../stylesheets/bootstrap_overrides.css'

import moment from 'moment'

// Global components
import Header from '../components/ui/header.vue'
import ShadowBox from '../components/ui/shadowBox.vue'
import Loader from '../components/ui/loader.vue';

Vue.component('app-header', Header)
Vue.component('app-shadow-box', ShadowBox)
Vue.component('app-loader', Loader)

//Mixins
import AxiosMixin from '../mixins/axiosMixin';
Vue.mixin(AxiosMixin)

// Filters

Vue.filter('localizeTimepicker', function (value) {
  if (!value) return ''
  var time = moment(value, 'HH:mm:ss');
  return time.format("h:mm a");
})

Vue.prototype.$adminCheck = function () {
  return isAdmin;
};

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#app',
    render: h => h(App)
  })
  console.log(app)
})
