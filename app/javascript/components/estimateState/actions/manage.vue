<template>
    <app-scrollable-sidebar :id='id' title='Manage State' submitText='Done' :onSubmit='handleDone' :cancellable='false'>
      <template v-slot:content>
        
        <app-select-field v-model="state" :options="options" label="State" name="state"/>

        <app-input-field v-model="reason" name="reason" label="Reason (optional)" v-if="reasonAllowed()"/>

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
        reason: this.estimate.state_reason
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

    },
    methods: {
      reasonAllowed() {
        return ['on_hold', 'unknown', 'cancelled'].includes(this.state);
      },
      updateEstimate() {
        let params = { estimate: { state: this.state, state_reason: this.reason } }
        if (!this.reasonAllowed()) {
          this.reason = null;
          params.estimate.state_reason = null;
        }

        this.axiosPut(`/estimates/${this.estimate.id}`, params)
          .then(response => {
            if (response.status === 200) {
              this.$root.$emit('bv::toggle::collapse', this.id);
              EventBus.$emit('ESTIMATE_UPDATED', { state: this.state, state_reason: this.reason, tags: this.estimateTags });
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
      }
    }
  }
</script>

<style scoped>


</style>