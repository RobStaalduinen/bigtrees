<template>
  <div id='form-buttons'>
    <button @click='back' v-if='displayBack && !loading' id='back-button'>
      <b-icon icon='arrow-left' id='left-icon'></b-icon>
      Back
    </button>
    <div v-if='!displayBack || loading' id='back-placeholder'>

    </div>


    <div v-if='!loading'>
      <button @click='forward' v-if='displayForward && !loading' id='forward-button'>
        {{ forwardText }}
        <b-icon icon='arrow-right' id='right-icon'></b-icon>
      </button>
    </div>
    <div v-else id='submit-button-loader'>
      <b-spinner></b-spinner>
    </div>
  </div>

</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  props: {
    displayBack: {
      required: false,
      default: true
    },
    displayForward: {
      required: false,
      default: true
    },
    forwardText: {
      required: false,
      default: 'Next'
    },
    loadingState: {
      required: false,
      default: false
    },
    nextValidation: {
      type: Function,
      required: false,
      default: () => { return Promise.resolve(true); }
    }
  },
  data() {
    return {
      loading: false
    }
  },
  methods: {
    back() {
      EventBus.$emit('form-back');
    },
    forward() {
      this.nextValidation().then(success => {
        if (success) {
          if(this.loadingState) {
            this.loading = true;
            console.log("SET LOADING");
          }
          EventBus.$emit('form-forward');
        }
        else {
          EventBus.$emit('form-error');
        }
      });
    }
  },
}
</script>

<style>

  #form-buttons {
    display: flex;
    justify-content: space-between;
    padding: 8px;

    border-width: 1px 0 0 0;
    border-style: solid;
    border-color: lightgray;
  }

  #back-button{
    border-width: 0;
    padding: 4px 16px;
    display: flex;
    align-items: center;

    background-color: transparent;
    color: var(--main-color);
  }

  #left-icon {
    margin-right: 8px;
    font-size: 18px;
  }

  #forward-button {
    color: white;
    background-color: var(--main-color);
    border-radius: 5px;
    border-width: 0;
    padding: 4px 16px;
    display: flex;
    align-items: center;
  }

  #submit-button-loader {
    margin-top: 4px;
    margin-right: 16px;
  }

  #right-icon {
    margin-left: 8px;
    font-size: 18px;
  }

  @media(max-width: 759px) {
    #form-buttons {
      position: fixed;
      bottom: 0;
      width: 100%;
      z-index: 1000;
      background-color: white;
    }
  }

</style>
