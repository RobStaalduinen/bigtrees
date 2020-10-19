<template>
  <div>
    <b-form-group label="Wood removal needed?">
      <b-form-radio-group
        v-model="questions.wood_removal"
        :options="options"
        name="wood-removal"
      ></b-form-radio-group>
    </b-form-group>

    <b-form-group label="Complete Cleanup?">
      <b-form-radio-group
        v-model="questions.cleanup"
        :options="options"
        name="cleanup"
      ></b-form-radio-group>
    </b-form-group>

    <b-form-group label="Vehicle Access?">
      <b-form-radio-group
        v-model="questions.vehicle_access"
        :options="options"
        name="vehicle-access"
      ></b-form-radio-group>
    </b-form-group>

    <b-form-group label="Access width under 36 inches?">
      <b-form-radio-group
        v-model="questions.low_access_width"
        :options="options"
        name="access-width"
      ></b-form-radio-group>
    </b-form-group>
  </div>  
</template>

<script>
export default {
  data(){
    return {
      questions: {
        wood_removal: true,
        cleanup: false,
        vehicle_access: false,
        low_access_width: false
      },
      options: [
        { text: 'Yes', value: true },
        { text: 'No', value: false }
      ]
    }
  },
  watch: {
    questions: function() {
      this.$emit('input', this.questions);
    }
  },
  mounted() {
    this.$emit('input', this.questions);
  }
  
}
</script>

<style scoped>

</style>
