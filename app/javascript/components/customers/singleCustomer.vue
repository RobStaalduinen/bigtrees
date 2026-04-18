<template>
  <div class='shadow-box-entry customer-list-entry'>
    <div class='customer-header'>
      <div class='customer-header-name'>{{ customer.name }}</div>
      <div class='customer-header-count'>{{ estimateCountText }}</div>
    </div>

    <div class='customer-list-body'>
      <div class='body-row' v-if='customer.address'>
        <b-icon icon='globe' class='contact-icon'></b-icon>
        {{ customer.address }}
      </div>

      <div class='body-row'>
        <template v-if='hasPhone || customer.email'>
          <template v-if='hasPhone'>
            <b-icon icon='telephone' class='contact-icon'></b-icon>
            <a :href="'tel:' + customer.phone">{{ customer.phone }}</a>
          </template>
          <template v-if='customer.email'>
            <b-icon icon='envelope' class='contact-icon' :class="{ 'icon-spaced': hasPhone }"></b-icon>
            <a :href="'mailto:' + customer.email">{{ customer.email }}</a>
          </template>
        </template>
        <span v-else class='no-contact'>No contact info</span>
      </div>

      <div class='body-row' v-if='customer.estimate_count > 0'>
        <b-icon icon='clock' class='contact-icon'></b-icon>
        {{ customer.last_estimate_status }}
        <span class='estimate-date'>· {{ customer.last_activity_date | shortDate }}</span>
      </div>
    </div>

    <div class='contact-actions'>
      <b-nav-item-dropdown id="customer-actions-dropdown" text="Actions" right>
        <b-dropdown-item :to='`/admin/estimates/${customer.recent_estimate_id}`'>
          Recent Estimate
        </b-dropdown-item>
        <b-dropdown-item :to='`/admin/estimates/new?customer_id=${customer.id}`'>
          New Estimate
        </b-dropdown-item>
      </b-nav-item-dropdown>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    'customer': {
      type: Object,
      required: true
    }
  },
  computed: {
    estimateCountText() {
      const n = this.customer.estimate_count;
      if (n === 0) return 'No estimates';
      if (n === 1) return '1 estimate';
      return `${n} estimates`;
    },
    hasPhone() {
      const p = this.customer.phone;
      return p !== null && p !== '' && p !== '0';
    }
  }
}
</script>

<style scoped>
  .customer-list-entry {
    width: 100%;
    margin-bottom: 8px;
    display: flex;
    flex-direction: column;
    padding: 8px;
  }

  .customer-header {
    display: flex;
    justify-content: space-between;
    border-width: 0 0 1px 0;
    border-color: lightgray;
    border-style: solid;
    margin: -8px -8px 8px -8px;
  }

  .customer-header-name {
    font-weight: 600;
    padding: 4px 4px 4px 8px;
  }

  .customer-header-count {
    font-size: 12px;
    color: #666;
    background-color: #f0f0f0;
    border-radius: 12px;
    padding: 2px 10px;
    align-self: center;
    margin-right: 4px;
  }

  .customer-list-body {
    display: flex;
    flex-direction: column;
    font-size: 14px;
    padding-left: 4px;
  }

  .body-row {
    display: flex;
    align-items: center;
    margin-bottom: 4px;
  }

  .contact-icon {
    color: var(--main-color);
    margin-right: 4px;
  }

  .icon-spaced {
    margin-left: 12px;
  }

  .no-contact {
    color: #999;
    font-style: italic;
  }

  .estimate-date {
    color: #999;
    margin-left: 4px;
  }

  .contact-actions {
    display: flex;
    justify-content: flex-end;
    font-size: 14px;
    border-width: 1px 0 0 0;
    border-color: lightgray;
    border-style: solid;
    margin: 0 -8px -8px -8px;
  }

  #customer-actions-dropdown {
    list-style: none;
  }

  #customer-actions-dropdown >>> a {
    padding: 6px 12px;
  }
</style>
