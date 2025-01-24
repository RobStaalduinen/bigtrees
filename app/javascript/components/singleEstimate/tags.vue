<template>
  <div>
    <app-collapsable id='tags-collapse'>
      <template v-slot:title>
        <b>Tags</b>
        <div id='tags-preview'>
          <app-tag-list :tags='estimate.tags' />
        </div>
      </template>

      <template v-slot:content>
        <div class='single-estimate-link-row'>
          <div class='single-estimate-link' v-b-toggle.manage-tags>
            Manage Tags
          </div>
        </div>
      </template>
    </app-collapsable>
    
    <app-manage-tags id='manage-tags' :estimate="estimate" />
  </div>
</template>

<script>
import TagList from '@/components/tags/views/list.vue'
import Manage from '@/components/tags/actions/manage_estimate.vue'

export default {
  components: {
    'app-tag-list': TagList,
    'app-manage-tags': Manage
  },
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
