<template>
  <app-right-sidebar :id='id' title='Add Image' submitText='Save' :onSubmit='saveImage' :validate='validate'>
    <template v-slot:content>
      <validation-observer ref="observer">
        <b-form-group
          label="Task"
          label-for="task"
        >
          <b-form-select
            v-model='taskNumber'
            name='task'
            :options="options"
          />
        </b-form-group>
        <app-single-image v-model='image'></app-single-image>

        <span class='submit-error' v-if='validationErrorMessage'>{{ validationErrorMessage }}</span>
      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import SingleImage from '../forms/single';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-single-image': SingleImage
  },
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
      image: {},
      taskNumber: 'new',
      validationErrorMessage: null
    }
  },
  computed: {
    options() {
      var arr =  this.estimate.trees.map((tree, index) => {
        return this.optionForTree(tree, index);
      })
      arr.unshift({value: 'new', text: 'New Task'});

      return arr;
    }
  },
  methods: {
    saveImage() {
      var params = {
        estimate_id: this.estimate.id,
        images: [this.image.url]
      }

      if(this.taskNumber != 'new') {
        params.tree_id = this.taskNumber
      }

      this.axiosPost('/tree_images/create_from_urls', params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
      })
    },
    optionForTree(tree, index){
      return {
        value: tree.id,
        text: `Task #${index+1}`
      }
    },
    validate() {
      var image = this.image;

      if(image.uploadCompleted == null){
        this.validationErrorMessage = 'Pleae add an image';
        return false;
      }

      if(image.uploadCompleted == false){
        this.validationErrorMessage = 'Wait for image uploads to finish and try again';
        return false;
      }

      this.validationErrorMessage = null;
      return true;
    }
  }
}
</script>

<style scoped>

</style>
