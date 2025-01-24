<template>
  <app-right-sidebar :id='id' :title='title' submitText='Submit' :onSubmit='submitTag'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-input-field
          v-model='label'
          name='label'
          label='Label'
          maxLength='20'
          validationRules='required'
        />

        <b-form-group label="Colour">
          <app-colour-picker
            v-model='colour'
            name='colour'
            label='Colour'
            validationRules='required'
          />
        </b-form-group>

        <b-form-group label="Example">
          <app-tag :tag='sampleTag' />
        </b-form-group>
      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>

import EventBus from '@/store/eventBus';

export default {
  components: {

  },
  props: {
    id: {
      required: true
    },
    organization_id: {
      required: true
    },
    tag: {
      required: false
    }
  },
  data() {
    return {
      label: null,
      colour: '#FF0000'
    }
  },
  computed: {
    title(){
      return this.tag ? 'Edit Tag' : 'Create Tag';
    },
    sampleTag(){
      return {
        label: this.label,
        colour: this.colour
      }
    }
  },
  methods: {
    submitTag() {
      this.$refs.observer.validate().then(success => {
        if (!success) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }

        if(this.tag){
          this.updateTag();
        } else {
          this.createTag();
        }
      });
    },
    createTag(){
      this.axiosPost(`/organizations/${this.organization_id}/tags`, {
        label: this.label,
        colour: this.colour
      }).then(response => {
        this.handleUpdate(response);
      });
    },

    updateTag(){
      this.axiosPut(`/organizations/${this.organization_id}/tags/${this.tag.id}`, {
        label: this.label,
        colour: this.colour
      }).then(response => {
        this.handleUpdate(response);
      });
    },
    handleUpdate(response){
      this.$root.$emit('bv::toggle::collapse', this.id);
      this.reset();
      this.$emit('changed', response.data.tag);
    },
    reset(){
      this.label = null;
      this.colour = '#FF0000';
    }
  },
  watch: {
    tag(){
      this.label = this.tag ? this.tag.label : null;
      this.colour = this.tag ? this.tag.colour : '#FF0000';
    }
  }
}
</script>