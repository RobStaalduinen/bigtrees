<template>
  <div id='onboarding-container'>
     <app-onboarding-progress-bar :percentage='progressPercentage'></app-onboarding-progress-bar>
     <transition name="fade">
      <app-onboarding-quantity
        v-if='currentPage == 1 && !changing'
        v-model='treeQuantity'
      ></app-onboarding-quantity>
     </transition>

     <transition name="fade">
      <app-onboarding-trees
        v-if='onTreePage() && !changing'
        :treeNumber='currentPage - 1'
        v-model='trees'
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
      customer: {}
    }
  },
  mounted() {
    if (window.location.href.includes('requests')) {
      this.context = 'Requests'
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
      return this.currentPage > 1 && this.currentPage <= 1 + parseInt(this.treeQuantity)
    },
    isTreePage(page) {
      return page > 1 && (page <= 1 + parseInt(this.treeQuantity));
    },
    totalPages() {
      return parseInt(this.treeQuantity) + 3;
    },
    stopTransition(previousPage, nextPage) {
      return this.isTreePage(previousPage) && this.isTreePage(nextPage)
    }
  },
  mounted() {
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
  min-height: 600px;
}

.form-label {
  margin-bottom: 8px;

  font-weight: 600;
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
  margin-left: 8px;
  width: 100%;
  margin-bottom: 0;
  padding: 4px;
}

.onboarding-form-radio-single > input {
  margin: 0;
}
</style>
