<template>
  <page-template>
    <app-header title='Organizations'></app-header>

    <div v-for='organization in organizations' :key='organization.id' class='organization-wrapper'>
      <app-collapsable-list-item :id='`organization-${organization.id}`'>
        <template v-slot:content>
          <div class='list-item-header'>
            <div class='list-item-header-left'>
              <b>{{ organization.name }}</b>
              <span v-if='organization.legal_name && organization.legal_name !== organization.name'> | {{ organization.legal_name }}</span>
            </div>
            <div class='list-item-header-right'>
              <span class='arborist-count'>{{ organization.arborists_count }} {{ organization.arborists_count === 1 ? 'user' : 'users' }}</span>
            </div>
          </div>

          <div class='list-item-content'>
            <div class='detail-row' v-if='organization.email'>
              <b-icon icon='envelope' class='app-icon detail-icon'></b-icon>
              <a :href="'mailto:' + organization.email">{{ organization.email }}</a>
            </div>
            <div class='detail-row' v-if='organization.phone_number'>
              <b-icon icon='telephone' class='app-icon detail-icon'></b-icon>
              <a :href="'tel:' + organization.phone_number">{{ organization.phone_number }}</a>
            </div>
            <div class='detail-row' v-if='organization.website'>
              <b-icon icon='globe' class='app-icon detail-icon'></b-icon>
              <span>{{ organization.website }}</span>
            </div>
          </div>
        </template>

        <template v-slot:collapsed>
          <app-collapsable-action-bar>
            <template v-slot:content>
            </template>
          </app-collapsable-action-bar>
        </template>
      </app-collapsable-list-item>
    </div>
  </page-template>
</template>

<script>
export default {
  data() {
    return {
      organizations: []
    }
  },
  methods: {
    retrieveOrganizations() {
      this.axiosGet('/organizations').then(response => {
        this.organizations = response.data.organizations;
      })
    }
  },
  mounted() {
    if (this.$store.state.user.user_id !== 14) {
      this.$router.push({ name: 'hours' });
      return;
    }
    this.retrieveOrganizations();
  }
}
</script>

<style scoped>
  .organization-wrapper {
    margin-bottom: 8px;
  }

  .list-item-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 12px;
  }

  .list-item-header-left {
    font-size: 14px;
  }

  .list-item-header-right {
    font-size: 12px;
    color: #666;
  }

  .arborist-count {
    background-color: #f0f0f0;
    border-radius: 12px;
    padding: 2px 10px;
  }

  .list-item-content {
    padding: 0 12px 8px;
    font-size: 12px;
  }

  .detail-row {
    margin-top: 2px;
    margin-bottom: 2px;
  }

  .detail-icon {
    margin-right: 4px;
  }
</style>
