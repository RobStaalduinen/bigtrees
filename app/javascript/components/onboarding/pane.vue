<template>
  <div class='onboarding-pane'>
    <div class='pane-side left-side'>
      <slot name='left-side' />

    </div>
    <div class='pane-side  right-side'>
      <slot name='right-side' />
      <slot name='controls' />
    </div>
  </div>
</template>

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

  padding: 8px;
}

.left-side {
  width: 50%;

  margin-right: 8px
}

.right-side {
  width: 50%;

  min-height: 500px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;

  margin-left: 8px;
}
</style>
