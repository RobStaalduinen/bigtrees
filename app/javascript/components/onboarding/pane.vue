<template>
  <div class='onboarding-pane'>
    <div class='pane-side left-side'>
      <slot name='left-side' />

    </div>
    <div class='pane-side  right-side'>
      <div>
        <div class='title'>
          {{ rightTitle }}
        </div>
        <div class='right-side-interior'>
          <slot name='right-side' />
        </div>
      </div>
      <slot name='controls' />
    </div>
  </div>
</template>

<script>
export default {
  props: ['rightTitle']
}
</script>

<style scoped>
.onboarding-pane {
  display: flex;

  min-height: 500px;
}

.pane-side {
  margin: 8px;

  border-width: 2px;
  border-color: lightgray;
  border-style: solid;
}

.left-side {
  width: 50%;

  margin-right: 8px;
  padding: 8px;
}

.right-side {
  width: 50%;

  min-height: 500px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;

  margin-left: 8px;
}

.right-side-interior {
  padding: 8px;
}

.title {
  color: white;
  background-color: var(--main-color);
  padding: 8px;
  text-align: center;
}
</style>
