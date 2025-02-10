<template>
  <div>
    <app-collapsable id='tags-collapse' :canExpand='false'>
      <template v-slot:title>
        <div class="title-container">
          <div class='title-row'>
            <div class="title-label"><b>State: </b></div>
            <div class="title-right">
              {{ formatState(estimate.state) }}

              <div class="edit-container" v-if="estimate.state != 'done'">
                <b-icon icon='pencil-square' class='app-icon edit-status-button' v-b-toggle.manage-state></b-icon>
              </div>
            </div>   
          </div>

          <div class='title-sub-row' v-if='estimate.state_reason'>
            <div class="title-label"><b>Reason: </b></div>
            <div class="title-right">
              {{ estimate.state_reason }}
            </div>
          </div>

          <div class='title-sub-row'>
            <div class="title-label"><b>Tags: </b></div>
            <div class="title-right" v-if="estimate.tags.length > 0">
              <app-tag-list :tags='estimate.tags' />
            </div>
            <div class='title-right' v-else><i>None</i></div>
          </div>
        </div>
      </template>
    </app-collapsable>
    
    <app-manage-state id='manage-state' :estimate="estimate" />
  </div>
</template>

<script>
import TagList from '@/components/tags/views/list.vue'
import Manage from '@/components/estimateState/actions/manage.vue'

export default {
  components: {
    'app-tag-list': TagList,
    'app-manage-state': Manage
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
    formatState(state) {
      return state.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
    }
  }
}
</script>

<style scoped>
  .title-right {
    display: flex;

    margin-left: 24px;
    width: 80%;
  }

  .title-label {
    width: 20%;
  }

  .title-separator {
    margin-left: 8px;
    margin-right: 8px;
  }

  .title-container {
    display: inline-block;
    width: 100%;
  }


  .title-row {
    display: flex;
    width: 100%;
  }

  .title-sub-row {
    display: flex;
    margin-top: 8px;
    width: 100%;
  }

  .edit-status-button {
    margin-left: 16px;
    cursor: pointer;
  }
</style>
