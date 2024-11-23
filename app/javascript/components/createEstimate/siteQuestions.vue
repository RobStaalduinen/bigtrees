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

    <b-form-group label="Breakables?">
      <b-form-radio-group
        v-model="questions.breakables"
        :options="options"
        name="breakables"
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
  props: ['value'],
  data(){
    return {
      questions: {
        wood_removal: this.withFallback(this.value.wood_removal, true),
        cleanup: this.withFallback(this.value.cleanup, false),
        vehicle_access: this.withFallback(this.value.vehicle_access, false),
        low_access_width: this.withFallback(this.value.low_access_width, false),
        breakables: this.withFallback(this.value.breakables, false)
      },
      options: [
        { text: 'Yes', value: true },
        { text: 'No', value: false }
      ]
    }
  },
  methods: {
    withFallback(val, fallback) {
      return val == null ? fallback : val
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
