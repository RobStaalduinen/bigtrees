
import Vue from 'vue'
import { BootstrapVue, IconsPlugin } from 'bootstrap-vue'
import { ValidationProvider, ValidationObserver } from 'vee-validate';

import { extend } from 'vee-validate';
import { required, email } from 'vee-validate/dist/rules';

extend('required', {
  ...required,
  message: 'This field is required'
});

Vue.component('ValidationProvider', ValidationProvider);
Vue.component('ValidationObserver', ValidationObserver);

Vue.use(BootstrapVue)
Vue.use(IconsPlugin)
Vue.use(require('vue-moment'));

import Onboarding from '../onboarding.vue'
import "vue-multiselect/dist/vue-multiselect.min.css"

import ShadowBox from '../components/ui/shadowBox.vue'
import Loader from '../components/ui/loader.vue';
import AppButton from '../components/ui/button.vue';

Vue.component('app-shadow-box', ShadowBox)
Vue.component('app-loader', Loader)
Vue.component('app-button', AppButton)

// Form components
// import SearchField from '../components/form/searchField.vue';
// import Pagination from '../components/form/pagination.vue';
// import ArrowPagination from '../components/form/arrowPagination.vue';
// import InputField from '../components/form/inputField.vue';
// import NumberField from '../components/form/numberField.vue';
// import SelectField from '../components/form/selectField';
// import DatePicker from '../components/form/datePicker.vue';
// import SubmitButton from '../components/form/submitButton.vue';
// import Multi from '../components/form/multiSelect.vue';
// import CheckboxHighlight from '../components/form/checkboxHighlight.vue';
// import CheckboxRightLabel from '../components/form/checkboxRightLabel.vue';
// import EmailContent from '../components/form/emailContent.vue';
// import ConditionalBox from '../components/form/conditionalBox.vue';

// Vue.component('app-search-field', SearchField);
// Vue.component('app-pagination', Pagination);
// Vue.component('app-arrow-pagination', ArrowPagination);
// Vue.component('app-input-field', InputField);
// Vue.component('app-number-field', NumberField);
// Vue.component('app-select-field', SelectField);
// Vue.component('app-submit-button', SubmitButton);
// Vue.component('app-multi-select', Multi);
// Vue.component('app-checkbox-highlight', CheckboxHighlight);
// Vue.component('app-datepicker', DatePicker);
// Vue.component('app-checkbox-right-label', CheckboxRightLabel);
// Vue.component('app-email-content', EmailContent);
// Vue.component('app-conditional-box', ConditionalBox);

//Mixins
import AxiosMixin from '../mixins/axiosMixin';
import PermissionMixin from '../mixins/permissionMixin';
Vue.mixin(AxiosMixin)
Vue.mixin(PermissionMixin)

import TurbolinksAdapter from 'vue-turbolinks';
Vue.use(TurbolinksAdapter);

// document.addEventListener('DOMContentLoaded', () => {
//   const app = new Vue({
//     el: '#onboarding',
//     render: h => h(Onboarding)
//   })
// })

document.addEventListener("turbolinks:load", () => {
  if(!document.getElementById('onboarding')) {
    return;
  }
  const app = new Vue({
    el: '#onboarding',
    render: h => h(Onboarding)
  })
})

// document.addEventListener('turbolinks:load', () => {
//   console.log("LOAD");
//   new Vue({
//     el: '#onboarding',
//     beforeMount() {
//         if (this.$el.parentNode) {
//             document.addEventListener('turbolinks:visit', () => this.$destroy(), { once: true });

//             this.$originalEl = this.$el.outerHTML;
//         }
//     },
//     destroyed() {
//         this.$el.outerHTML = this.$originalEl;
//     }
//   });
// });
