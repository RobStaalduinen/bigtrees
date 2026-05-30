<template>
    <app-scrollable-sidebar :id='id' title='Manage State' submitText='Done' :onSubmit='handleDone' :cancellable='false'>
      <template v-slot:content>
        
        <app-select-field v-model="state" :options="options" label="State" name="state"/>

        <app-input-field v-model="reason" name="reason" label="Reason (optional)" v-if="reasonAllowed()"/>

        <app-select-field v-model="difficulty" :options="difficultyOptions" label="Difficulty" name="difficulty"/>

        <app-manage-tags :id="id" :estimate="estimate" @tagsChanged="cacheTags"/>
      </template>
    </app-scrollable-sidebar>

</template>

<script>
  import EventBus from '@/store/eventBus';
  import ManageTags from '@/components/tags/views/manageEstimate.vue';

  export default {
    components: {
      'app-manage-tags': ManageTags
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
        organization: this.$store.state.organization,
        organizationTags: [],
        addableTags: [],
        estimateTags: this.estimate.tags,
        state: this.estimate.state,
        reason: this.estimate.state_reason,
        difficulty: this.estimate.difficulty
      }
    },
    computed: {
      options() {
        return ['in_progress', 'on_hold', 'unknown', 'done', 'cancelled'].map(option => {
          return {
            value: option,
            text: option.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase())
          };
        });
      },
      difficultyOptions() {
        return [
          { value: 'easy', text: 'Easy' },
          { value: 'medium', text: 'Medium' },
          { value: 'hard', text: 'Hard' }
        ];
      }
    },
    methods: {
      reasonAllowed() {
        return ['on_hold', 'unknown', 'cancelled'].includes(this.state);
      },
      updateEstimate() {
        console.log("Updating.");
        let params = { estimate: { state: this.state, state_reason: this.reason, difficulty: this.difficulty } }
        if (!this.reasonAllowed()) {
          this.reason = null;
          params.estimate.state_reason = null;
        }

        this.axiosPut(`/estimates/${this.estimate.id}`, params)
          .then(response => {
            if (response.status === 200) {
              this.$root.$emit('bv::toggle::collapse', this.id);
              EventBus.$emit('ESTIMATE_UPDATED', { state: this.state, state_reason: this.reason, difficulty: this.difficulty, tags: this.estimateTags });
            }
          })
      },
      handleDone(){
        this.updateEstimate();
      },
      cacheTags(newTags) {
        this.estimateTags = newTags;
      }
    },
    watch: {
      'estimate.state'(newVal) {
        this.state = newVal;
      },
      'estimate.difficulty'(newVal) {
        this.difficulty = newVal;
      }
    }
  }
</script>

<style scoped>


</style>