<template>
  <button @click='handleClick'>
    <b-icon :icon="icon" v-if="icon != null" class='button-icon'></b-icon>

    {{ text }}
  </button>
</template>

<script>
export default {
  props: {
    text: {
      required: true,
      type: String
    },
    icon: {
      type: String
    },
    click: {
      type: Function,
      required: false
    }
  },
  methods: {
    handleClick() {
      if (this.click) {
        this.click();
      }
    }
  }
}
</script>

<style scoped>
  button {
    border-radius: 5px;
    font-size: 14px;
    border-width: 1px;
    border-color: gray;
    background-color: #eeeeee;
    padding: 1px 10px;
    display: flex;
    align-items: center;
  }

  .button-icon {
    margin-right: 4px;
  }
</style>
