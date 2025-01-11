<template>
  <app-right-sidebar :id='id' title='Add Images' submitText='Save' :onSubmit='saveImage' :validate='validate'>
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

        <app-multi-image
          v-model='images'
          accept=".jpg, .jpeg, .png"
          bucketName='tree_images'
          name='image'

        ></app-multi-image>

        <span class='submit-error' v-if='validationErrorMessage'>{{ validationErrorMessage }}</span>
      </validation-observer>
    </template>
  </app-right-sidebar>
</template>

<script>
import SingleImage from '../forms/single';
import MultiImage from '@/components/file/actions/multiUpload';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-single-image': SingleImage,
    'app-multi-image': MultiImage
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
      images: [],
      taskNumber: null,
      validationErrorMessage: null
    }
  },
  computed: {
    options() {
      var arr =  this.estimate.trees.map((tree, index) => {
        return this.optionForTree(tree, index);
      })
      arr.unshift({value: 'new', text: 'New Task'});
      arr.unshift({value: null, text: 'Uncategorized'});

      return arr;
    }
  },
  methods: {
    saveImage() {
      var params = {
        estimate_id: this.estimate.id,
        images: this.images.map(image => image.url)
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
      if(this.images.length == 0){
        this.validationErrorMessage = 'Please add at least one image';
        EventBus.$emit('FORM_VALIDATION_FAILED');
        return false;
      }
      
      for(var i = 0; i < this.images.length; i++){
        if(this.images[i].uploading == true){
          this.validationErrorMessage = 'Wait for image uploads to finish and try again';
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return false;
        }
      }

      return true;

      var image = this.image;

      if(image.uploadCompleted == null){
        this.validationErrorMessage = 'Pleae add an image';
        EventBus.$emit('FORM_VALIDATION_FAILED');
        return false;
      }

      if(image.uploadCompleted == false){
        this.validationErrorMessage = 'Wait for image uploads to finish and try again';
        EventBus.$emit('FORM_VALIDATION_FAILED');
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
