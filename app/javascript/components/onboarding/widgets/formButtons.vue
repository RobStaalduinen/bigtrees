<template>
  <div id='form-buttons'>
    <button @click='back' v-if='displayBack' id='back-button'>
      <b-icon icon='arrow-left' id='left-icon'></b-icon>
      Back
    </button>
    <div v-if='!displayBack' id='back-placeholder'>

    </div>
    <button @click='forward' v-if='displayForward' id='forward-button'>
      Next
      <b-icon icon='arrow-right' id='right-icon'></b-icon>
    </button>
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
    }
  },
  methods: {
    back() {
      EventBus.$emit('form-back');
    },
    forward() {
      EventBus.$emit('form-forward');
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

  #right-icon {
    margin-left: 8px;
    font-size: 18px;
  }

</style>
