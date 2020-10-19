<template>
  <section class='form-section shadow-box-entry'>
    <div class='form-section-header'>
      {{ header }}
    </div>
    <div>
      <slot></slot>
    </div>
  </section>
</template>

<script>
export default {
  props: {
    header: { 
      required: true,
      type: String
    }
  }
}
</script>

<style scoped>
  .form-section {
    padding: 8px;
    border: 1px lightgray solid;
    margin-bottom: 8px;

  }

  .form-section-header {
    font-weight: 600;
    color: var(--main-color);
    font-size: 14px;
    margin-bottom: 8px;
    border-width: 0 0 1px 0;
    border-color: lightgray;
    border-style: solid;
  }
</style>
