<template>
  <div id='onboarding-container' class='container' v-if='!loading'>
    <div v-if='standalone && logoUrl'>
      <img :src='logoUrl' id='onboarding-logo'>
    </div>

     <template v-if='!this.formSubmitted'>
      <app-onboarding-progress-bar :percentage='progressPercentage'></app-onboarding-progress-bar>
      <transition name="fade">
        <app-onboarding-quantity
          v-if='currentPage == 1 && !changing'
          v-model='treeQuantity'
          :stumpingOnly='stumpingOnly'
        ></app-onboarding-quantity>
      </transition>

      <transition name="fade">
        <app-onboarding-trees
          v-if='onTreePage() && !changing'
          :treeNumber='currentPage - 1'
          v-model='trees'
          :stumpingOnly='stumpingOnly'
        ></app-onboarding-trees>
      </transition>

      <transition name="fade">
          <app-onboarding-site
            v-if='currentPage == (parseInt(treeQuantity) + 2) && !changing'
            v-model='site'
          ></app-onboarding-site>
        </transition>

        <transition name='fade'>
          <app-onboarding-contact
            v-if='currentPage == (parseInt(treeQuantity) + 3) && !changing'
            v-model='customer'
          ></app-onboarding-contact>
        </transition>
      </template>
      <template v-if='this.formSubmitted'>
        <div id = 'thank-you-display'>
          Thank you for your request! <br/> <br/>
          We will review your job and get back to you with your estimate as soon as we possibly can.
        </div>
      </template>
  </div>
</template>

<script>
import Quantity from './components/onboarding/pages/quantity';
import Trees from './components/onboarding/pages/trees';
import Site from './components/onboarding/pages/site';
import Contact from './components/onboarding/pages/contact';
import ProgressBar from './components/onboarding/progressBar'

import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-onboarding-quantity': Quantity,
    'app-onboarding-trees': Trees,
    'app-onboarding-site': Site,
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
      site: {},
      customer: {},
      organizationShortname: null,
      organizationData: {},
      loading: true,
      logoUrl: null,
      standalone: true,
      formSubmitted: false,
      stumpingOnly: false
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

      console.log("Last Page status: ", this.lastPage());
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
      return this.currentPage > 1 && this.currentPage <= 1 + parseInt(this.treeQuantity)
    },
    isTreePage(page) {
      return page > 1 && (page <= 1 + parseInt(this.treeQuantity));
    },
    totalPages() {
      return parseInt(this.treeQuantity) + 3;
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
      if(!this.standalone) {
        this.loading = false;
        return;
      }
      this.organizationShortname = document.getElementById('onboarding-top-level').getAttribute('data-organization_shortname');

      this.axiosGet(`/organizations/public/${this.organizationShortname}`).then(response => {
        if(response.status == 200) {
          this.organizationData = response.data;
          console.log(this.organizationData);

          document.documentElement.style.setProperty('--main-color', this.organizationData.primary_colour);

          this.logoUrl = this.organizationData.logo_url;

          this.loading = false;
        }
      })
    },
    submitForm() {
      let params = {
        trees: this.trees.slice(0, this.treeQuantity),
        site: this.site,
        customer: this.customer,
        organization_shortname: this.organizationShortname
      }

      this.axiosPost('/customer_requests', params).then(response => {
        if(response.status == 200) {
          let thankYouPage = document.getElementById('onboarding-top-level').getAttribute('data-thank-you-page');
          if(thankYouPage != null) {
            window.location.href = thankYouPage;
          }
          else {
            this.formSubmitted = true;
          }
        }
      })
    }
  },
  mounted() {
    this.setFormType();
    this.setOrganization();
    EventBus.$on('form-forward', () => { this.advance() } )
    EventBus.$on('form-back', () => { this.goBack() } )
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

@media(min-width: 760px) {
  #onboarding-container {
    min-height: 600px;
    padding: 16px;
  }
}
</style>
