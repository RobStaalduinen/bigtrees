<template>
  <div>
    <app-collapsable id='tags-collapse'>
      <template v-slot:title>
        <b>Tags</b>
        <div id='tags-preview'>
          <app-tag color='yellow' v-if='estimate.site_visit_required'>Site Visit</app-tag>
        </div>
      </template>

      <template v-slot:content>

      </template>

    </app-collapsable>

  </div>
</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  props: {
    estimate: {
      required: true,
      type: Object
    }
  },
  data(){
    return {
    }
  },
  computed: {

  },
  methods: {

  }
}
</script>

<style scoped>
  #tags-preview {
    display: flex;

    margin-left: 24px;
  }
</style>
