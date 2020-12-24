<template>
  <b-sidebar :id='id' right shadow no-header lazy class='right-sidebar'>
    <div id='edit-sidebar'>
      <div id='edit-header'>{{ title }}</div>
      <slot name='content'></slot>
    </div>

    <div id='submission'>
      <b-button type='submit' class='inverse-button sidebar-button' v-b-toggle='id'>Cancel</b-button>
      <b-button type='submit' class='submit-button sidebar-button' @click='onSubmit'>{{ submitText }}</b-button>
    </div>
  </b-sidebar>
</template>

<script>
export default {
  props: {
    title: {
      default: 'Edit Item'
    },
    id: {
      required: true
    },
    submitText: {
      required: false,
      default: 'Submit'
    },
    onSubmit: {
      required: false,
      type: Function
    }
  }
}
</script>

<style scoped>
  #edit-sidebar {
    padding: 8px;
    padding-top: 32px;
    position: relative;
    margin-bottom: 48px;
  }

  #edit-header {
    font-size: 22px;
    font-weight: 600;

    border-style: solid;
    border-width: 0 0 1px 0;
    border-color: var(--main-color);

    margin-bottom: 8px;
  }

  #submission {
    width: 100%;
    display: flex;
    justify-content: flex-end;

    position: absolute;
    bottom: 0;
    left: 0;

    padding: 4px;

    border-width: 1px 0 0 0;
    border-color: lightgray;
    border-style: solid;

    z-index: 2;
    background-color: white;
  }

  .sidebar-button {
    width: 50%;
  }

  .inverse-button {
    margin-right: 8px;
  }
</style>
