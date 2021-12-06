<template>
  <b-sidebar :id='id' right shadow no-header lazy class='right-sidebar' @shown='broadcastShown' ref='sidebar'>
    <div id='edit-sidebar'>
      <div id='edit-header'>{{ title }}</div>
      <slot name='content'></slot>
    </div>

    <div id='submission'>
      <div id='submission-container'>
        <template v-if='!submitting'>
          <b-button type='submit' class='inverse-button sidebar-button' @click='cancel'>Cancel</b-button>
          <b-button type='submit' class='inverse-button sidebar-button' v-if='alternateAction' @click='() => alternateAction()'>
            {{ alternateActionText }}
          </b-button>
          <div class='sidebar-button'>
            <app-submit-button :label='submitText' :onSubmit='submit' :displaySpinner='false'></app-submit-button>
          </div>
        </template>
        <div v-else>
          <b-spinner id='submit-button-loader'></b-spinner>
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
    alternateActionText: {
      required: false,
      default: 'Skip'
    },
    onSubmit: {
      required: false,
      type: Function
    },
    submitting: {
      required: false,
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      submissionStatus: this.submitting
    }
  },
  watch: {
    submitting() {
      this.submissionStatus = this.submitting;
    }
  },
  methods: {
    submit() {
      this.onSubmit();
      // var validationStatus = true;
      // if(this.validate != undefined || this.validate != null) {
      //   validationStatus = this.validate();
      // }

      // if(validationStatus){
      //   this.onSubmit();
      //   this.$emit('completed');
      // }
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

  #submission-container {
    width: 100%;
    display: flex;
    justify-content: center;
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
