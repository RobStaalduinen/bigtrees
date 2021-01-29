<template>
  <div class='shadow-box-entry estimate'>
    <div class='estimate-header'>
      <div class='estimate-header-name'>{{ estimate.customer.name }}</div>
      <div class='estimate-header-status'>{{ estimate.formatted_status }}</div>
    </div>

    <div class='estimate-body'>

      <div class='contact-row'>
        <div class='estimate-body-row' v-if='estimate.site.address'>
          <b-icon icon='globe' class='contact-icon'></b-icon>
          {{ estimate.site.address.full_address }}
        </div>
        <div class='estimate-additional-message' v-if='estimate.additional_message != null'>{{ estimate.additional_message }}</div>
      </div>
      <div class='estimate-body-row'>
        <b-icon icon='telephone' class='contact-icon'></b-icon>
        <a :href="'tel:' + estimate.customer.phone">{{ estimate.customer.phone }}</a>
        <b-icon icon='envelope' class='contact-icon' id='email-row'></b-icon>
        <a :href="'mailto:' + estimate.customer.email">{{ estimate.customer.email }}</a>
      </div>
    </div>

    <div class='estimate-footer'>
      <app-estimate-actions-list :estimate='estimate'></app-estimate-actions-list>

      <a class='estimate-link' v-b-modal='"timelineModal" + estimate.id'>
        Timeline
      </a>

      <a class='estimate-link' @click='openImages' v-if='hasImages()'>
        Images
      </a>

      <router-link class='estimate-link' :to='"/admin/estimates/" + estimate.id'>
        Details
      </router-link>
    </div>

    <app-timeline-modal :estimate='estimate' :modalId='"timelineModal" + estimate.id'></app-timeline-modal>
  </div>
</template>

<script>
import TimelineModal from './timelineModal';
import ActionsList from './actionsList';
import EventBus from '@/store/eventBus'

export default {
  props: {
    'estimate':{
      type: Object,
      required: true
    }
  },
  components: {
    'app-timeline-modal': TimelineModal,
    'app-estimate-actions-list': ActionsList
  },
  methods:
  {
    openImages() {
      EventBus.$emit('TOGGLE_IMAGE_GALLERY', { estimate: this.estimate })
    },
    hasImages() {
      return this.estimate.trees.map(tree => {
        return tree.tree_images.length > 0
      }).some(img => img === true);
    }
  }
}
</script>

<style scoped>
  .estimate {
    width: 100%;
    margin-bottom: 8px;
    display: flex;
    flex-direction: column;
    font-size: 12px;
  }

  .estimate-header {
    display: flex;
    justify-content: space-between;

    border-width: 0 0 1px 0;
    border-color: lightgray;
    border-style: solid;

    margin-bottom: 8px;
  }

  .estimate-header-name {
    font-weight: 600;
    padding: 4px;
  }

  .estimate-additional-message {
    font-size: 10px;
    display: flex;
    align-items: center;
  }

  .estimate-header-status {
    background-color: var(--secondary-red);
    color: white;
    min-width: 30%;
    display: flex;
    justify-content: center;
    padding: 4px;
  }

  .estimate-body {
    display: flex;
    flex-direction: column;
    font-size: 12px;
    padding-left: 4px;

    border-width: 0 0 1px 0;
    border-color: lightgray;
    border-style: solid;
  }

  .estimate-body-row {
    display: flex;
    align-items: center;
    margin-bottom: 6px;
  }

  .contact-row {
    display: flex;
    justify-content: space-between;
    padding-right: 6px;
    align-items: flex-start;
  }

  #email-row{
    margin-left: 12px;
  }

  .contact-icon {
    color: var(--main-color);
    margin-right: 4px;
  }

  .estimate-footer {
    display: flex;
    justify-content: flex-end;
  }

  .estimate-link {
    padding: 6px 12px;

    border-width: 0 0 0 1px;
    border-color: lightgray;
    border-style: solid;
  }

</style>
