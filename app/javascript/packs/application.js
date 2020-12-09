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
import VueRouter from 'vue-router';
import { ValidationProvider, ValidationObserver } from 'vee-validate';
import { extend } from 'vee-validate';
import { required, email } from 'vee-validate/dist/rules';

Vue.component('ValidationProvider', ValidationProvider);
Vue.component('ValidationObserver', ValidationObserver);

extend('required', {
  ...required,
  message: 'This field is required'
});


Vue.use(BootstrapVue)
Vue.use(IconsPlugin)
Vue.use(VueRouter);
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
import LoadingOverlay from '../components/ui/loadingOverlay.vue';
import AppButton from '../components/ui/button.vue';
import PageTemplate from '../components/templates/pageTemplate.vue';

Vue.component('app-header', Header)
Vue.component('app-shadow-box', ShadowBox)
Vue.component('app-loader', Loader)
Vue.component('app-loading-overlay', LoadingOverlay)
Vue.component('page-template', PageTemplate)
Vue.component('app-button', AppButton)


// Form components
import SearchField from '../components/form/searchField.vue';
import Pagination from '../components/form/pagination.vue';
import ArrowPagination from '../components/form/arrowPagination.vue';
import InputField from '../components/form/inputField.vue';

Vue.component('app-search-field', SearchField);
Vue.component('app-pagination', Pagination);
Vue.component('app-arrow-pagination', ArrowPagination);
Vue.component('app-input-field', InputField);

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

// Pages
import Hours from '../pages/hours.vue'
import Customers from '../pages/customers.vue'
import Estimates from '../pages/estimates.vue'
import CreateEstimate from '../pages/createEstimate.vue'

const routes = [
  { path: '/admin/hours', component: Hours },
  { path: '/admin/customers', component: Customers },
  { path: '/admin/estimates', component: Estimates },
  { path: '/admin/estimates/new', component: CreateEstimate }
]

const router = new VueRouter({
  mode: 'history',
  routes: routes
})

import { store } from '../store/store.js';

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#app',
    router: router,
    render: h => h(App),
    store: store
  })
  console.log(app)
})