<template>
  <div class='onboarding-pane'>
    <div class='pane-side left-side'>
      <slot name='left-side' />

    </div>
    <div class='pane-side  right-side'>
      <slot name='right-side' />
    </div>
  </div>
</template>

<style scoped>
.onboarding-pane {
  display: flex;
}

.pane-side {
  margin: 8px;
}

.left-side {
  width: 50%;

  border-width: 0 1px 0 0;
  border-color: var(--main-color);
  border-style: solid;
}

.right-side {
  width: 50%;
}
</style>
