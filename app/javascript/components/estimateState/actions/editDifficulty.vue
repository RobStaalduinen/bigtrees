<template>
  <app-scrollable-sidebar :id='id' title='Difficulty' submitText='Save' :onSubmit='handleSubmit'>
    <template v-slot:content>
      <app-select-field v-model='difficulty' :options='options' label='Difficulty' name='difficulty'/>
    </template>
  </app-scrollable-sidebar>
</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  props: {
    id: { required: true },
    estimate: { required: true }
  },
  data() {
    return {
      difficulty: this.estimate.difficulty
    }
  },
  computed: {
    options() {
      return [
        { value: 'easy', text: 'Easy' },
        { value: 'medium', text: 'Medium' },
        { value: 'hard', text: 'Hard' }
      ];
    }
  },
  methods: {
    handleSubmit() {
      const params = { estimate: { difficulty: this.difficulty } };

      this.axiosPut(`/estimates/${this.estimate.id}`, params)
        .then(response => {
          if (response.status === 200) {
            this.$root.$emit('bv::toggle::collapse', this.id);
            EventBus.$emit('ESTIMATE_UPDATED', { difficulty: this.difficulty });
          }
        });
    }
  },
  watch: {
    'estimate.difficulty'(newVal) {
      this.difficulty = newVal;
    }
  }
}
</script>
