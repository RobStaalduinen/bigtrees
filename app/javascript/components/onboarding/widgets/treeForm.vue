<template>
  <div>

      <b-form-group>
        <div class='form-label'>
          What type of work is required?
        </div>

        <b-form-select v-model="work_type" :options="options"></b-form-select>
      </b-form-group>

      <div v-if='work_type == 0'>
        <b-form-group>
          <div class='form-label'>
            Do you need the stump removed as well?
          </div>
          <div class='onboarding-form-radios'>
            <b-form-radio v-model="stump_removal" value=false class='onboarding-form-radio-single'>No</b-form-radio>
            <b-form-radio v-model="stump_removal" value=true class='onboarding-form-radio-single'>Yes</b-form-radio>
          </div>
        </b-form-group>
      </div>

      <b-form-group>
        <div class='form-label'>
          Can you desribe the job?
        </div>

        <b-form-textarea
          id="textarea"
          name='notes'
          :value="notes"
          @input='(value) => updateNotes(value)'
          rows="3"
          max-rows="3"
          :placeholder='helpContent'
          no-resize
        ></b-form-textarea>
      </b-form-group>

      <b-form-group>
        <div class='form-label'>
          Images
        </div>
        <div v-for="(image, index) in images" :key='`tree_${treeNumber}_image_${index}`'>
          <app-file-upload
            :value='image'
            @input='(url) => updateImage(index, url)'
            accept=".jpg, .jpeg, .png"
          ></app-file-upload>
        </div>
      </b-form-group>
  </div>
</template>

<script>
import Uploader from '@/components/file/actions/upload';

export default {
  components: {
    'app-file-upload': Uploader
  },
  props: ['treeNumber', 'value'],
  data() {
    return {
      options: [
        { value: 0, text: 'Tree Removal' },
        { value: 1, text: 'Trim' },
        { value: 2, text: 'Broken Limbs' },
        { value: 3, text: 'Stump Removal' },
        { value: 6, text: 'Other Tree Services' },
      ],
      stump_removal: false,
      images: this.value.images || [null],
      notes: this.value.notes || "",
      work_type: this.value.work_type || 0,
      helpContent: ""
    }
  },
  computed: {
    tree() {
      return {
        work_type: this.work_type,
        images: this.images,
        notes: this.notes
      }
    }
  },
  methods: {
    updateImage(index, image_url) {
      this.images[index] = image_url;
      this.adjustImageArray();
    },
    adjustImageArray() {
      this.images = this.images.filter(image => image);

      if(this.images.length < 3) {
        this.images.push(null);
      }
    },
    updateNotes(value) {
      this.notes = value;
    },
    setWorkTypeContent() {
      switch(this.work_type){
        case 0:
          this.helpContent = "Where is the tree located? Are there any special conditions we should be aware of? What is your plan for the space after removal?"
          break;
        case 1:
          this.helpContent = "Is your goal to to: Reduce the height, Raise the canopy, Trim away from your house, General cleanup, or something else entirely?"
          break;
        case 2:
          this.helpContent = "What is the approximate height of the broken limbs? What is the their current state?"
          break;
        case 3:
          this.helpContent = "What is the approximate size of the stump? \n After the stump is removed, do you plan to: plant grass, replant a tree, put in a driveway, add a building etc."
          break;
        case 6:
          this.helpContent = "Any details you can give us on your tree service needs will be incredibly helpful in forming your quote."
          break;
        default:
          this.helpContent = ""
      }
    }
  },
  watch: {
    tree() {
      this.$emit('input', this.tree)
    },
    work_type() {
      this.setWorkTypeContent();
    }
  },
  mounted() {
    this.setWorkTypeContent();
  }
}
</script>

<style>
.custom-file-label {
  display: none;
}
</style>
