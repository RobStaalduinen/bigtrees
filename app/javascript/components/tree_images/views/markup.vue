<template>
  <div id='edit-modal' @click.stop>
    <div id='edit-modal-internal'>
      <div id="image-container" v-if='!renderCanvas'>
        <img
          :src='imageUrl'
          id='edited-image'
          ref='image'
          @load='setupCanvas'
        />
      </div>

      <!-- <div id="image-container">
        <img
          :src='imageUrl'
          id='edited-image'
          ref='image'
        />
      </div> -->
        <!--
        <template v-if='renderCanvas'>
          <Editor :canvasWidth='canvasWidth' :canvasHeight='canvasHeight' ref='editor'></Editor>
        </template> -->

        <div id='editor-wrapper'>
          <tui-image-editor ref='editor' :include-ui='false' :options='options' class='image-editor'></tui-image-editor>
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
import ImageEditor from '@toast-ui/vue-image-editor/src/ImageEditor.vue'

export default {
  components: {
    'tui-image-editor': ImageEditor
  },
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
      selectedColor: 'red',
      options: {
        cssMaxWidth: 1500,
        cssMaxHeight: 1500
      }
    }
  },
  methods: {
    setColor(newColor){
      this.selectedColor = newColor;
      this.$refs.editor.invoke('setBrush', { color: this.selectedColor, width: 8 });
      // this.$refs.editor.set(this.editMode, { stroke: this.selectedColor });
    },
    undo(){
      let isEmpty = this.$refs.editor.invoke('isEmptyUndoStack');

      if(!isEmpty) {
        this.$refs.editor.invoke('undo');
      }
      // this.$refs.editor.setBackgroundImage(this.imageUrl);
    },
    redo(){
      // this.$refs.editor.redo();
    },
    cancel() {
      this.$emit('cancel');
    },
    save() {
      // this.onSave(this.$refs.editor.saveImage())
      this.onSave(this.$refs.editor.invoke('toDataURL'));
      // const dataUrl = this.$refs.editor.invoke('toDataURL');
      // console.log(dataUrl);
    },
    setupCanvas() {
      this.canvasWidth = this.$refs.image.clientWidth;
      this.canvasHeight = this.$refs.image.clientHeight;

      console.log(this.canvasWidth);
      console.log(this.canvasHeight);

      this.$refs.editor.invoke('loadImageFromURL', this.urlToEdit, 'Test.png').then(() => {
        this.$refs.editor.invoke('resizeCanvasDimension', { width: this.canvasWidth, height: this.canvasHeight }).then(() => {
          this.$refs.editor.invoke('clearUndoStack');
        });
      });
      this.renderCanvas = true;


      // this.$nextTick(() => {
      //   this.renderCanvas = true;

      //   this.$nextTick(() => {
      //     this.$refs.editor.set(this.editMode, { stroke: this.selectedColor });
      //     this.$refs.editor.setBackgroundImage(this.urlToEdit);
      //   })
      // })
    }
  },
  mounted() {
    // console.log(this.$refs.editor);
    // console.log(this.urlToEdit);
    // this.$refs.editor.invoke('loadImageFromURL', this.urlToEdit, 'Test.png').then(() => {
    //   this.$refs.editor.invoke('resizeCanvasDimension', { width: 800, height: 120 })
    // });
    this.$refs.editor.invoke('startDrawingMode', 'FREE_DRAWING', { color: 'red', width: 8 })
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

  #editor-wrapper {
    height: 80%;
    width: 100%;
    display: flex;
    justify-content: center;
  }

  .image-editor {
    display: flex;
    justify-content: center;
    align-items: center;
  }

  #edit-controls {
    background-color: white;
    width: 100%;

    display: flex;
    flex-direction: column;
    padding-bottom: 32px;
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

    #editor-wrapper {
      width: 60%;
    }
  }
</style>
