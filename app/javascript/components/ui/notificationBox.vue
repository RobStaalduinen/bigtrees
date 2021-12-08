<template>
  <div id='message-box-container' :class="{'hidden': isHidden }">
    <div id='message-box'>
      {{ message }}
    </div>
  </div>
</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  data(){
    return {
      isHidden: true,
      message: null
    }
  },
  mounted() {
    EventBus.$on('DISPLAY_MESSAGE', (message) => {
      this.setAlert(message);
    })
  },
  methods: {
    setAlert(message) {
      this.message = message;
      this.isHidden = false

      setTimeout(() => {
        this.isHidden = true;
      }, 5000)
    }
  }

}
</script>

<style scoped>
  #message-box-container {
    display: flex;
    justify-content: center;
  }

  #message-box {
    width: 98%;
    margin: 0 auto;
    background-color:rgb(167, 243, 157);
    color: rgb(36, 36, 36);
    opacity: 0.9;
    padding: 4px;
    text-align: center;

    position: fixed;
    bottom: 10px;
  }

  .hidden {
    visibility: hidden;
    opacity: 0;
    transition: visibility 0s 2s, opacity 2s linear;
  }

  @media(min-width: 760px) {
    #message-box {
      width: 50%;
    }
  }

</style>
