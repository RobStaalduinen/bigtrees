<template>
  <div id='onboarding-container' class='container' v-if='!loading' :class="{ 'embedded': !standalone }">
    <div v-if='standalone && logoUrl'>
      <img :src='logoUrl' id='onboarding-logo'>
    </div>

     <template v-if='!this.formSubmitted'>
      <app-onboarding-progress-bar :percentage='progressPercentage'></app-onboarding-progress-bar>

      <transition name="fade">
        <app-onboarding-initial
          v-if='currentPage == 1 && !changing'
          v-model='quoteOption'
        ></app-onboarding-initial>
      </transition>

      <!--Quote group -->
      <template v-if='quoteOption == "quote"'>
        <transition name="fade">
          <app-onboarding-quantity
            v-if='currentPage == 2 && !changing'
            v-model='treeQuantity'
            :stumpingOnly='stumpingOnly'
            :standalone='standalone'
          ></app-onboarding-quantity>
        </transition>

        <transition name="fade">
          <app-onboarding-trees
            v-if='onTreePage() && !changing'
            :treeNumber='currentPage - 2'
            v-model='trees'
            :stumpingOnly='stumpingOnly'
            :standalone='standalone'
          ></app-onboarding-trees>
        </transition>

        <transition name="fade">
            <app-onboarding-site
              v-if='currentPage == (parseInt(treeQuantity) + 3) && !changing'
              v-model='site'
              :standalone='standalone'
            ></app-onboarding-site>
          </transition>

          <transition name='fade'>
            <app-onboarding-contact
              v-if='currentPage == (parseInt(treeQuantity) + 4) && !changing'
              v-model='customer'
              :standalone='standalone'
            ></app-onboarding-contact>
          </transition>
        </template>

        <!--Visit group -->
        <template v-if='quoteOption == "visit"'>
          <transition name="fade">
            <app-onboarding-site-visit
              v-if='currentPage == 2 && !changing'
              v-model='site'
             :standalone='standalone'
            ></app-onboarding-site-visit>
          </transition>

          <transition name="fade">
            <app-onboarding-contact
              v-if='currentPage == 3 && !changing'
              v-model='customer'
              :standalone='standalone'
            ></app-onboarding-contact>
          </transition>
        </template>

        <!--Contact group -->
        <template v-if='quoteOption == "contact"'>
          <transition name="fade">
            <app-onboarding-contact
              v-if='currentPage == 2 && !changing'
              v-model='customer'
              subtype='commercial_quote'
              :standalone='standalone'
            ></app-onboarding-contact>
          </transition>
        </template>

      </template>
      <template v-if='this.formSubmitted'>
        <div id = 'thank-you-display'>
          Thank you for your request! <br/> <br/>
          We will review your job and get back to you with your estimate as soon as we possibly can.

          <div v-if='organizationData.quote_redirect_link'>
            <button class='redirect-button' @click='redirectHome'>Return to Home</button>
          </div>
        </div>
      </template>
  </div>
</template>

<script>
import Initial from './components/onboarding/pages/initial';
import Quantity from './components/onboarding/pages/quantity';
import Trees from './components/onboarding/pages/trees';
import Site from './components/onboarding/pages/site';
import Contact from './components/onboarding/pages/contact';
import SiteVisit from './components/onboarding/pages/siteVisit';
import ContactUs from './components/onboarding/pages/contact_us';
import ProgressBar from './components/onboarding/progressBar'

import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-onboarding-initial': Initial,
    'app-onboarding-quantity': Quantity,
    'app-onboarding-trees': Trees,
    'app-onboarding-site': Site,
    'app-onboarding-site-visit': SiteVisit,
    'app-onboarding-contact': Contact,
    'app-onboarding-progress-bar': ProgressBar
  },
  data() {
    return {
      context: null,
      currentPage: 1,
      changing: false,
      treeQuantity: 1,
      trees: [{}, {}, {}],
      site: { address_attributes: {} },
      customer: {},
      organizationShortname: null,
      organizationData: {},
      loading: true,
      logoUrl: null,
      standalone: true,
      formSubmitted: false,
      stumpingOnly: false,
      quoteOption: null
    }
  },
  computed: {
    progressPercentage() {
      let percentComplete = ((this.currentPage - 1) / (this.totalPages())) * 100
      return Math.max(percentComplete, 2);
    }
  },
  methods: {
    advance() {
      if(this.lastPage()) {
        this.submitForm();
        return;
      }

      if(!this.stopTransition(this.currentPage, this.currentPage + 1)) {
        this.changing = true;

        setTimeout(() => {
          this.changing = false
        }, 550)
      }

      this.currentPage += 1;
    },
    goBack() {
      if(this.currentPage == 1) {
        return;
      };

      if(!this.stopTransition(this.currentPage, this.currentPage - 1)) {
        this.changing = true;

        setTimeout(() => {
          this.changing = false
        }, 550)
      }

      this.currentPage -= 1;
    },
    onTreePage() {
      return this.currentPage > 2 && this.currentPage <= 2 + parseInt(this.treeQuantity)
    },
    totalPages() {
      if (this.quoteOption == 'quote') {
        return parseInt(this.treeQuantity) + 4;
      }
      else if(this.quoteOption == 'contact') {
        return 2;
      }
      else if(this.quoteOption == 'visit') {
        return 3;
      }
      else {
        return 1;
      }
    },
    lastPage() {
      return this.currentPage == this.totalPages();
    },
    stopTransition(previousPage, nextPage) {
      return false;
    },
    setFormType() {
      if(document.getElementById('onboarding-top-level').getAttribute('data-form-type') == 'standalone') {
        this.standalone = true;
      }
      else {
        this.standalone = false;
      }

      if(document.getElementById('onboarding-top-level').getAttribute('data-stumping-only') == 'true') {
        this.stumpingOnly = true;
      }
    },
    setOrganization() {
      this.organizationShortname = document.getElementById('onboarding-top-level').getAttribute('data-organization_shortname');

      if(!this.standalone) {
        this.loading = false;
        return;
      }

      this.axiosGet(`/organizations/public/${this.organizationShortname}`).then(response => {
        if(response.status == 200) {
          this.organizationData = response.data.organization;

          document.documentElement.style.setProperty('--main-color', this.organizationData.primary_colour);

          this.logoUrl = this.organizationData.logo_url;

          this.loading = false;
        }
      })
    },
    submitForm() {
      if(this.quoteOption == 'quote') {
        this.submitRequest();
      }
      else if (this.quoteOption == 'visit') {
        this.submitVisit();
      }
      else {
        this.submitContact();
      }
    },
    submitRequest() {
      let params = {
        trees: this.trees.slice(0, this.treeQuantity),
        site: this.site,
        customer: this.customer,
        organization_shortname: this.organizationShortname
      }

      this.axiosPost('/customer_requests', params).then(response => {
        if(response.status == 200) {
          this.moveToThankYou();
        }
      })
    },
    submitVisit() {
      let params = {
        site: this.site,
        customer: this.customer,
        organization_shortname: this.organizationShortname,
        trees: [],
        site_visit: true
      }

      this.axiosPost('/customer_requests', params).then(response => {
        if(response.status == 200) {
          this.moveToThankYou();
        }
      })
    },
    submitContact() {
      let params = {
        commercial_request: {
          name: this.customer.name,
          email: this.customer.email,
          phone: this.customer.phone
        },
        organization_id: this.organizationData.id
      }

      this.axiosPost('/commercial_requests', params).then(response => {
        if(response.status == 200) {
          this.moveToThankYou()
        }
      })
    },
    moveToThankYou() {
      let thankYouPage = document.getElementById('onboarding-top-level').getAttribute('data-thank-you-page');
      if(thankYouPage != null) {
        window.location.href = thankYouPage;
      }
      else {
        this.formSubmitted = true;
      }
    },
    redirectHome() {
      window.location.href = this.organizationData.quote_redirect_link;
    }
  },
  mounted() {
    this.setFormType();
    this.setOrganization();
    EventBus.$on('form-forward', () => { this.advance() } )
    EventBus.$on('form-back', () => { this.goBack() } )
  },
  watch: {
    quoteOption() {
      if(this.quoteOption) {
        this.advance();
      }
    }
  }
}
</script>

<style>
.fade-enter-active, .fade-leave-active {
  transition: opacity .5s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}

#onboarding-container {
  padding: 0;
}

#thank-you-display {
  margin-top: 20px;
  border-width: 5px 0 0 0;
  border-style: solid;
  border-color: var(--main-color);
  padding: 8px;
  padding-top: 24px;
  font-size: 20px;
  text-align: center;
}

.redirect-button {
  background-color: var(--main-color);
  color: white;
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  margin-top: 16px;
  cursor: pointer;
}


.form-label {
  margin-bottom: 8px;

  font-weight: 600;
}

.form-subtext {
  color: grey;
  font-size: 14px;
  font-weight: 400;
}

.form-group {
  border-width: 0 0 1px 0;
  border-color: #efefef;
  border-style: solid;
  padding-bottom: 8px;
}

.onboarding-form-radios {
  display: flex
}


.onboarding-form-radio-single {
  width: auto;
  display: flex;
  align-items: center;
  margin-right: 32px
}

.onboarding-form-radio-single > label{
  width: 100%;
  margin-bottom: 0;
  padding: 4px;
  padding-left: 12px;
}

.onboarding-form-radio-single > input {
  margin: 0;
}

#onboarding-logo {
  width: 100%;
  max-width: 200px;
  margin: 0 auto;
  display: block;
  margin-bottom: 8px;
}

.embedded {
  min-height: 400px;
  position: relative;
}

@media(min-width: 760px) {
  #onboarding-container {
    min-height: 600px;
    padding: 16px;
  }
}
</style>
