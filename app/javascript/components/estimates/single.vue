<template>
  <div class='shadow-box-entry estimate'>
    <div class='estimate-header'>
      <div class='estimate-header-name'>{{ estimate.customer_detail.name }}</div>
      <div v-if='estimate.is_unknown' class='estimate-unknown-header'>Unknown</div>
      <div class='estimate-header-status'>{{ estimate.formatted_status }}</div>
    </div>

    <div class='estimate-body'>
      <div class='estimate-body-row' v-if='mySchedule'>
        <b-icon icon='clock' class='contact-icon'></b-icon>
        {{ estimate.work_start_date | localizeDate }} - {{ estimate.work_end_date | localizeDate }}
      </div>

      <div class='contact-row'>
        <div class='estimate-body-row' v-if='estimate.customer.name != estimate.customer_detail.name'>
          <span>Parent Customer: &nbsp;</span>
          {{ estimate.customer.name }}
        </div>
      </div>

      <div class='contact-row'>
        <div class='estimate-body-row' v-if='estimate.site && estimate.site.address'>
          <b-icon icon='globe' class='contact-icon'></b-icon>
          <a :href="'http://maps.google.com/?q=' + encodeURIComponent(estimate.site.address.full_address)" target='_blank'>
            {{ estimate.site.address.full_address }}
          </a>
        </div>
        <div class='estimate-additional-message' v-if='estimate.additional_message != null'>{{ estimate.additional_message }}</div>
      </div>
      <div class='estimate-body-row'>
        <b-icon icon='telephone' class='contact-icon'></b-icon>
        <a :href="'tel:' + estimate.customer_detail.phone">{{ estimate.customer_detail.phone }}</a>
        <b-icon icon='envelope' class='contact-icon' id='email-row'></b-icon>
        <a :href="'mailto:' + estimate.customer_detail.email">{{ estimate.customer_detail.email }}</a>
      </div>
    </div>

    <div class='estimate-footer'>
      <app-estimate-actions-list :estimate='estimate'></app-estimate-actions-list>

      <!-- <a class='estimate-link' v-b-modal='"timelineModal" + estimate.id'>
        Timeline
      </a> -->

      <!-- <a class='estimate-link' @click='openImages' v-if='hasImages()'>
        Images
      </a> -->

      <router-link class='estimate-link' :to='"/admin/estimates/" + estimate.id'>
        Details
      </router-link>
    </div>

    <!-- <app-timeline-modal :estimate='estimate' :modalId='"timelineModal" + estimate.id'></app-timeline-modal> -->
    <!-- <app-image-gallery :estimate='estimate'></app-image-gallery> -->
  </div>
</template>

<script>
import TimelineModal from './timelineModal';
import ActionsList from './actionsList';
import ImageGallery from '@/components/tree_images/views/galleryModal';
import EventBus from '@/store/eventBus'
import { mapState } from 'vuex'

export default {
  props: {
    'estimate':{
      type: Object,
      required: true
    }
  },
  components: {
    'app-timeline-modal': TimelineModal,
    'app-estimate-actions-list': ActionsList,
    'app-image-gallery': ImageGallery
  },
  computed: mapState({
    mySchedule: state => state.estimateSettings.mySchedule
  }),
  methods:
  {
    openImages() {
      EventBus.$emit('TOGGLE_IMAGE_GALLERY', { estimate_id: this.estimate.id })
    }
    // hasImages() {
    //   return this.estimate.trees.map(tree => {
    //     return tree.tree_images.length > 0
    //   }).some(img => img === true);
    // }
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

  .estimate-unknown-header {
    display: flex;
    align-items: center;
    font-style: italic;
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
