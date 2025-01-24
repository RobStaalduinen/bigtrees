<template>
  <b-sidebar :id='id' right shadow no-header lazy class='right-sidebar' @shown='broadcastShown' ref='sidebar'>
    <div style='display: flex; flex-direction: column; justify-content: space-between; height: 100%;'>

      <div id='sidebar-top'>
        <div id='edit-header'>{{ title }}</div>
        <slot name='content'></slot>
      </div>

      <div class='sidebar-bottom'>
        <slot name='extras'></slot>
        <div id='submission'>
          <b-button type='submit' class='inverse-button sidebar-button' @click='cancel' v-if="cancellable">Cancel</b-button>
          <b-button type='submit' class='inverse-button sidebar-button' v-if='alternateAction' @click='() => alternateAction()'>
            {{ alternateActionText }}
          </b-button>
          <div class='sidebar-button'>
            <app-submit-button :label='submitText' :onSubmit='submit'></app-submit-button>
          </div>
        </div>
      </div>

    </div>
  </b-sidebar>
</template>

<script>
import EventBus from '@/store/eventBus'

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
    alternateAction: {
      required: false,
      type: Function
    },
    cancellable: {
      required: false,
      default: true
    },
    alternateActionText: {
      required: false,
      default: 'Skip'
    },
    onSubmit: {
      required: false,
      type: Function
    },
    validate: {
      required: false,
      type: Function
    }
  },
  methods: {
    submit() {
      var validationStatus = true;
      if(this.validate != undefined || this.validate != null) {
        validationStatus = this.validate();
      }

      if(validationStatus){
        this.onSubmit();
        this.$emit('completed');
      }
    },
    cancel(){
      this.$root.$emit('bv::toggle::collapse', this.id);
      this.$emit('cancelled');
    },
    broadcastShown() {
      EventBus.$emit('TOGGLE_SIDEBAR', this.id);

    }
  },
  mounted() {
    EventBus.$on('TOGGLE_SIDEBAR', (open_id) => {
      if(this.$refs.sidebar && this.$refs.sidebar.isOpen){
        if(open_id != this.id) {
          this.$root.$emit('bv::toggle::collapse', this.id);
        }
      }
    });
  }
}
</script>

<style scoped>
  #sidebar-top {
    padding: 8px;
    padding-top: 32px;
    max-height: 90%;
    overflow: scroll;
  }

  #sidebar-bottom {
    display: flex;
    flex-direction: column;
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
    padding: 4px;

    border-width: 1px 0 0 0;
    border-color: lightgray;
    border-style: solid;

    z-index: 2;
    background-color: white;
  }

  .sidebar-button {
    width: 100%;
    display: flex;
    justify-content: center;
  }

  .inverse-button {
    margin-right: 8px;
  }
</style>
