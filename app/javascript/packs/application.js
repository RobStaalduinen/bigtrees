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
import Editor from 'vue-image-markup';

Vue.component('ValidationProvider', ValidationProvider);
Vue.component('ValidationObserver', ValidationObserver);
Vue.component('Editor', Editor);

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
import "vue-multiselect/dist/vue-multiselect.min.css"
import '../stylesheets/variables'
import '../stylesheets/bootstrap_overrides.css'
import '../stylesheets/common_styles.css'
import '../stylesheets/ui_styles.css'

import moment from 'moment'

import Multiselect from 'vue-multiselect';
import { ToggleButton } from 'vue-js-toggle-button';

Vue.component('multiselect', Multiselect)
Vue.component('toggle-button', ToggleButton)

// Global components
import Header from '../components/ui/header.vue'
import ShadowBox from '../components/ui/shadowBox.vue'
import Loader from '../components/ui/loader.vue';
import LoadingOverlay from '../components/ui/loadingOverlay.vue';
import AppButton from '../components/ui/button.vue';
import PageTemplate from '../components/templates/pageTemplate.vue';
import Collapsable from '../components/ui/collapsable.vue';
import CollapsableListItem from '../components/ui/collapsableListItem.vue';
import CollapsableActionBar from '../components/ui/collapsableActionBar.vue';
import ActionBarItem from '../components/ui/actionBarItem.vue';
import RightSidebar from '../components/ui/rightSidebar.vue';
import ScrollableRightSidebar from '../components/ui/scrollableRightSidebar.vue';

Vue.component('app-header', Header)
Vue.component('app-shadow-box', ShadowBox)
Vue.component('app-loader', Loader)
Vue.component('app-loading-overlay', LoadingOverlay)
Vue.component('page-template', PageTemplate)
Vue.component('app-button', AppButton)
Vue.component('app-collapsable', Collapsable)
Vue.component('app-collapsable-list-item', CollapsableListItem)
Vue.component('app-collapsable-action-bar', CollapsableActionBar)
Vue.component('app-action-bar-item', ActionBarItem)
Vue.component('app-right-sidebar', RightSidebar)
Vue.component('app-scrollable-sidebar', ScrollableRightSidebar)


// Form components
import SearchField from '../components/form/searchField.vue';
import Pagination from '../components/form/pagination.vue';
import ArrowPagination from '../components/form/arrowPagination.vue';
import InputField from '../components/form/inputField.vue';
import NumberField from '../components/form/numberField.vue';
import SelectField from '../components/form/selectField';
import DatePicker from '../components/form/datePicker.vue';
import SubmitButton from '../components/form/submitButton.vue';
import Multi from '../components/form/multiSelect.vue';
import CheckboxHighlight from '../components/form/checkboxHighlight.vue';

Vue.component('app-search-field', SearchField);
Vue.component('app-pagination', Pagination);
Vue.component('app-arrow-pagination', ArrowPagination);
Vue.component('app-input-field', InputField);
Vue.component('app-number-field', NumberField);
Vue.component('app-select-field', SelectField);
Vue.component('app-submit-button', SubmitButton);
Vue.component('app-multi-select', Multi);
Vue.component('app-checkbox-highlight', CheckboxHighlight);
Vue.component('app-datepicker', DatePicker);

//Mixins
import AxiosMixin from '../mixins/axiosMixin';
import PermissionMixin from '../mixins/permissionMixin';
Vue.mixin(AxiosMixin)
Vue.mixin(PermissionMixin)

// Filters

Vue.filter('localizeTimepicker', function (value) {
  if (!value) return ''
  var time = moment(value, 'HH:mm:ss');
  return time.format("h:mm a");
})

Vue.filter('currency', function (value) {
  if (typeof value !== "number") {
      return value;
  }
  var formatter = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
  });
  return formatter.format(value);
});

Vue.filter('localizeDate', function(date) {
  return moment(date).format('MMMM Do, YYYY');
})

// Pages
import Hours from '../pages/hours.vue'
import Customers from '../pages/customers.vue'
import Estimates from '../pages/estimates.vue'
import CreateEstimate from '../pages/createEstimate.vue'
import SingleEstimate from '../pages/singleEstimate.vue'
import Users from '../pages/users.vue';
import Equipment from '../pages/equipment.vue';
import Receipts from '../pages/receipts.vue';

import { store } from '../store/store.js';

const routes = [
  { path: '/admin/hours', component: Hours, name: 'hours' },
  { path: '/admin/customers', component: Customers },
  {
    path: '/admin/estimates',
    component: Estimates,
    meta: {
      authRequired: true,
      permission: { page: 'estimates', permission_type: 'list' }
    }
  },
  {
    path: '/admin/receipts',
    component: Receipts ,
    meta: {
      authRequired: true,
      permission: { page: 'receipts', permission_type: 'list' }
    }
  },
  { path: '/admin/estimates/new', component: CreateEstimate },
  { path: '/admin/estimates/:estimate_id', component: SingleEstimate },
  { path: '/admin/users/:user_id', component: Users, name: 'profile' },
  { path: '/admin/equipment', component: Equipment }
]


const router = new VueRouter({
  mode: 'history',
  routes: routes
})

router.beforeEach(async (to, from, next) => {
  if(!store.state.user.logged_in) {
    await store.dispatch('authenticate');

    // Still not authenticated, redirect to login
    if(!store.state.user.logged_in) {
      window.location.href = '/login'
    }
  }
  if (to.meta.authRequired) {
    var authRequirement = to.meta.permission;
    if(store.getters.hasPermission(authRequirement.page, authRequirement.permission_type)){
      next();
    }
    else{
      console.log(from);
      next({ name: 'hours' })
    }
  }
  else {
    next();
  }

})

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#app',
    router: router,
    render: h => h(App),
    store: store
  })
  console.log(app)
})
