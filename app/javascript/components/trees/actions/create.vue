<template>
  <app-right-sidebar :id='id' title='Add Task' submitText='Save' :onSubmit='saveTask' :validate='validate'>
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
      work_type: 0,
      stump_removal: false,
      in_backyard: false,
      description: null,
      validationErrorMessage: null
    }
  },
  computed: {
    options() {
      return [
        {value: 0, text: 'Removal'},
        {value: 1, text: 'Trim'},
        {value: 2, text: 'Broken Limbs'},
        {value: 3, text: 'Stump Removal'},
        {value: 4, text: 'Other'},
        {value: 5, text: 'Tree Services'}
      ]
    }
  },
  methods: {
    saveTask() {
      // this.axiosPost to /trees
      let params = {
        work_type: this.work_type,
        stump_removal: this.stump_removal,
        description: this.description,
        estimate_id: this.estimate.id
      }

      this.axiosPost('/trees/admin_create', params)
        .then(response => {
          let newTrees = this.estimate.trees.concat([response.data.tree])
          EventBus.$emit('ESTIMATE_UPDATED', { trees: newTrees });
          this.$root.$emit('bv::toggle::collapse', this.id);
        })
        .catch(error => {
          console.log(error);
        })
    },
    validate() {


      return true;
    }
  }
}
</script>
