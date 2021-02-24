<template>
  <div id='edit-modal' @click.stop>
    <div id='edit-modal-internal'>
      <div id="image-container">
        <img
          :src='imageUrl'
          id='edited-image'
          ref='image'
          v-if='!renderCanvas'
          @load='setupCanvas'
        />
        <template v-if='renderCanvas'>
          <Editor :canvasWidth='canvasWidth' :canvasHeight='canvasHeight' ref='editor'></Editor>
        </template>
      </div>
      <div id="edit-controls">
        <div class='edit-controls-row'>
          <div id='color-controls'>
            <div
              class='single-color'
              style='background-color: red'
              v-bind:class="{ 'single-color-active': selectedColor == 'red' }"
              @click='setColor("red")'
            ></div>

            <div
              class='single-color'
              style='background-color: blue'
              v-bind:class="{ 'single-color-active': selectedColor == 'blue' }"
              @click='setColor("blue")'
            ></div>

            <div
              class='single-color'
              style='background-color: yellow'
              v-bind:class="{ 'single-color-active': selectedColor == 'yellow' }"
              @click='setColor("yellow")'
            ></div>
          </div>

          <div id='undo-controls'>
            <b-icon
              icon='arrow-counterclockwise'
              class='undo-control-icon'
              @click='undo'
            ></b-icon>
          </div>
        </div>

        <div class="edit-controls-row edit-controls-save-row">
          <b-button
            type='submit'
            class='inverse-button'
            @click='cancel'
          >Cancel</b-button>

          <div class='sidebar-button' style='margin-left: 16px;'>
            <app-submit-button
              label='Save'
              :onSubmit='save'
            ></app-submit-button>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script>


export default {
  props: {
    imageUrl: {
      required: true,
      type: String
    },
    onSave: {
      required: true,
      type: Function
    }
  },
  data() {
    return {
      urlToEdit: this.imageUrl,
      editMode: 'freeDrawing',
      canvasWidth: null,
      canvasHeight: null,
      renderCanvas: false,
      selectedColor: 'red'
    }
  },
  methods: {
    setColor(newColor){
      this.selectedColor = newColor;
      this.$refs.editor.set(this.editMode, { stroke: this.selectedColor });
    },
    undo(){
      this.$refs.editor.clear();
      this.$refs.editor.setBackgroundImage(this.imageUrl);
    },
    redo(){
      this.$refs.editor.redo();
    },
    cancel() {
      this.$emit('cancel');
    },
    save() {
      this.onSave(this.$refs.editor.saveImage())
    },
    setupCanvas() {
      this.canvasWidth = this.$refs.image.clientWidth;
      this.canvasHeight = this.$refs.image.clientHeight;

      this.$nextTick(() => {
        this.renderCanvas = true;

        this.$nextTick(() => {
          this.$refs.editor.set(this.editMode, { stroke: this.selectedColor });
          this.$refs.editor.setBackgroundImage(this.urlToEdit);
        })
      })
    }
  }
}
</script>

<style scoped>
  #edit-modal {
    background-color: black;
    position: fixed;
    width: 100%;
    height: 100%;
    left: 0;
    top: 0;

    z-index: 200;
  }

  #edit-modal-internal{
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    align-items: center;
  }

  #image-container {
    display: flex;
    justify-content: center;
    height: 90%;
    padding-top: 16px;
    margin-bottom: 16px;
    width: 96%;
    margin-left: auto;
    margin-right: auto;
  }

  #edited-image {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
  }

  #edit-controls {
    background-color: white;
    width: 100%;

    display: flex;
    flex-direction: column;
  }

  .edit-controls-row {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    width: 100%;
    padding: 8px;
  }

  .edit-controls-save-row{
    justify-content: flex-end;
    border-width: 1px 0 0 0;
    border-color: lightgray;
    border-style: solid;
    padding-top: 4px;
  }

  #color-controls {
    display: flex;
  }

  #undo-controls {
    display: flex;
    align-items: center;
  }

  .undo-control-icon {
    margin-right: 16px;
    font-size: 22px;
  }

  .single-color {
    border-radius: 50%;
    margin-right: 16px;
    width: 30px;
    height: 30px;
    border: 3px white solid;
  }

  .single-color-active {
    border: 3px lightblue solid;
  }

  @media(min-width: 760px) {
    #image-container {
      height: 85%;
    }

    #edit-controls {
      width: 50%;
    }
  }
</style>
