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
      <div class='estimate-footer-left'>
        <app-tag-list :tags='estimate.tags'></app-tag-list>
      </div>

      <div class='estimate-footer-right'>
        <app-estimate-actions-list :estimate='estimate'></app-estimate-actions-list>

        <router-link class='estimate-link' :to='"/admin/estimates/" + estimate.id'>
          Details
        </router-link>
      </div>
    </div>

  </div>
</template>

<script>
import TimelineModal from './timelineModal';
import ActionsList from './actionsList';
import EventBus from '@/store/eventBus'
import { mapState } from 'vuex'
import TagList from '@/components/tags/views/list.vue'

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
    'app-tag-list': TagList
  },
  computed: mapState({
    mySchedule: state => state.estimateSettings.mySchedule
  }),
  methods:
  {

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
    justify-content: space-between;
  }

  .estimate-footer-left {
    display: flex;
    align-items: center;
    padding-left: 8px;
  }

  .estimate-footer-right {
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
