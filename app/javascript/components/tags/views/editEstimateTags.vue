<template>
  <app-scrollable-sidebar :id='id' title='Tags' submitText='Done' :onSubmit='handleDone' :cancellable='false'>
    <template v-slot:content>
      <app-manage-tags :id='id' :estimate='estimate' @tagsChanged='cacheTags'/>
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
    id: { required: true },
    estimate: { required: true }
  },
  data() {
    return {
      estimateTags: this.estimate.tags
    }
  },
  methods: {
    cacheTags(newTags) {
      this.estimateTags = newTags;
    },
    handleDone() {
      this.$root.$emit('bv::toggle::collapse', this.id);
      EventBus.$emit('ESTIMATE_UPDATED', { tags: this.estimateTags });
    }
  }
}
</script>
