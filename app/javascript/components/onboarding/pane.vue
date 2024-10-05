<template>
  <div class='onboarding-pane'>
    <div class='pane-side left-side'>
        <div>
        <div class='title'>
          {{ formTitle }}
        </div>
        <div class='left-side-interior'>
          <slot name='left-side' />
        </div>
      </div>
      <slot name='controls' />

    </div>
    <div class='pane-side right-side'>
      <div class='info-title'>
        More Information
      </div>
      <div class='right-side-interior'>
        <slot name='right-side' />
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: ['formTitle']
}
</script>

<style scoped>
.onboarding-pane {
  display: flex;

  min-height: 500px;
}

.pane-side {
  margin-top: 8px;

  border-width: 2px;
  border-color: lightgray;
  border-style: solid;
}

.left-side {
  width: 50%;
  margin-right: 8px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.right-side {
  width: 50%;

  min-height: 500px;
  display: flex;
  flex-direction: column;

  margin-left: 8px;
}

.right-side-interior {
  padding: 8px;
}

.left-side-interior {
  padding: 8px;
}

.title {
  color: white;
  background-color: var(--main-color);
  padding: 8px;
  text-align: center;
}

.info-title{
  background-color: lightgray;
  padding: 8px;
  text-align: center;
}

@media(max-width: 759px) {
  .pane-side {
    border-width: 0px;
    margin: 0px;
    margin-top: 8px;
  }

  .right-side {
    display: none;
  }

  .left-side {
    width: 100%;
    margin-right: 0px;
    margin-bottom: 64px;
  }
}

</style>
