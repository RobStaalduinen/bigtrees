<template>
  <app-right-sidebar :id='id' :title="isEditing ? 'Edit Task' : 'Add Task'" submitText='Save' :onSubmit='saveTask' :validate='validate'>
    <template v-slot:content>
      <validation-observer ref="observer">

        <b-form-group
          label="Task Type"
          label-for="task"
          >
          <b-form-select
            v-model='work_type'
            name='task'
            :options="options"
          />
        </b-form-group>

        <b-form-group
          label="Stump Removal"
          label-for="stump_removal"
          >
          <b-form-radio-group
            v-model='stump_removal'
            name='stump_removal'
            buttons
            >
            <b-form-radio value="true">Yes</b-form-radio>
            <b-form-radio value="false">No</b-form-radio>
          </b-form-radio-group>
        </b-form-group>

        <b-form-group
          label="In Backyard"
          label-for="in_backyard"
          >
          <b-form-radio-group
            v-model='in_backyard'
            name='in_backyard'
            buttons
            >
            <b-form-radio value="true">Yes</b-form-radio>
            <b-form-radio value="false">No</b-form-radio>
          </b-form-radio-group>
        </b-form-group>

        <b-form-group
          label="Desription (optional)"
          label-for="task"
        >
          <b-form-textarea
            v-model='description'
            name='description'
          ></b-form-textarea>
        </b-form-group>


        <span class='submit-error' v-if='validationErrorMessage'>{{ validationErrorMessage }}</span>
      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import EventBus from '@/store/eventBus';

export default {

  props: {
    id: {
      required: true
    },
    estimate: {
      required: true
    }
  },
  data() {
    return {
      work_type: 'removal',
      stump_removal: 'false',
      in_backyard: 'false',
      description: null,
      // Set when the form is opened to edit an existing task; null = create.
      editingTreeId: null,
      validationErrorMessage: null
    }
  },
  computed: {
    isEditing() {
      return this.editingTreeId != null;
    },
    // Values are enum keys so they round-trip directly to/from the serialized
    // tree's work_type (no index mapping needed for edit pre-fill).
    options() {
      return [
        {value: 'removal', text: 'Removal'},
        {value: 'trim', text: 'Trim'},
        {value: 'broken_limbs', text: 'Broken Limbs'},
        {value: 'stump_removal', text: 'Stump Removal'},
        {value: 'other', text: 'Other'},
        {value: 'tree_services', text: 'Tree Services'}
      ]
    }
  },
  methods: {
    saveTask() {
      const params = {
        work_type: this.work_type,
        stump_removal: this.stump_removal,
        in_backyard: this.in_backyard,
        description: this.description,
        estimate_id: this.estimate.id
      }

      const request = this.isEditing
        ? this.axiosPut(`/trees/${this.editingTreeId}/admin_update`, params)
        : this.axiosPost('/trees/admin_create', params);

      request
        .then(response => {
          const tree = response.data.tree || response.data;
          const trees = this.isEditing
            ? this.estimate.trees.map(t => (t.id === tree.id ? tree : t))
            : this.estimate.trees.concat([tree]);
          EventBus.$emit('ESTIMATE_UPDATED', { trees });
          this.$root.$emit('bv::toggle::collapse', this.id);
        })
        .catch(error => {
          console.log(error);
        })
    },
    validate() {
      return true;
    },
    // Open blank for a new task.
    resetForm() {
      this.work_type = 'removal';
      this.stump_removal = 'false';
      this.in_backyard = 'false';
      this.description = null;
      this.editingTreeId = null;
      this.validationErrorMessage = null;
    },
    // Pre-fill from an existing task and open the sidebar. Booleans become the
    // radio group's string values so the right option shows selected.
    loadForEdit(tree) {
      this.work_type = tree.work_type;
      this.stump_removal = tree.stump_removal ? 'true' : 'false';
      this.in_backyard = tree.in_backyard ? 'true' : 'false';
      this.description = tree.description;
      this.editingTreeId = tree.id;
      this.validationErrorMessage = null;
      this.$root.$emit('bv::toggle::collapse', this.id);
    }
  },
  mounted() {
    this._onEdit = (tree) => this.loadForEdit(tree);
    this._onReset = () => this.resetForm();
    EventBus.$on('TREE_FORM_EDIT', this._onEdit);
    EventBus.$on('TREE_FORM_RESET', this._onReset);
  },
  beforeDestroy() {
    EventBus.$off('TREE_FORM_EDIT', this._onEdit);
    EventBus.$off('TREE_FORM_RESET', this._onReset);
  }
}
</script>
