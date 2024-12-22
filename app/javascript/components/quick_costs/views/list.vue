<template>
  <div>
    <app-header title='Quick Cost Buttons'>
      <template v-slot:header-right>
        <div v-if='limitReached'>Limit Reached</div>
        <a v-b-toggle.create-cost v-if='hasPermission("quick_costs", "create") && !limitReached'>
          New
        </a>
      </template>
    </app-header>

    <div class='quick-cost-description'>
      You can define <b>up to 15</b> quick costs that can be added to invoices. These will be available as shortcuts to add common costs to invoices.
    </div>

    <div id='quick-cost-list'>
      <div class='quick-cost-header'>
        <div class='quick-cost-label quick-cost-header-text'>Button</div>
        <div class='quick-cost-value quick-cost-header-text'>Text</div>
        <div class='quick-cost-default quick-cost-header-text'>Value</div>
      </div>

      <div class='quick-cost-row' v-for='(cost, index) in quick_costs' :key='index'>
        <div class='quick-cost'>
          <div class='quick-cost-label'>{{ cost.label }}</div>
          <div class='quick-cost-value'>{{ cost.content }}</div>
          <div class='quick-cost-default'>{{ cost.default_cost }}</div>
          <div class='quick-cost-icons'>
            <b-icon class='quick-cost-icon' icon='pencil' @click='editCost(cost)'></b-icon>
            <b-icon class='quick-cost-icon' icon='trash' @click='deleteCost(cost)'></b-icon>
          </div>
        </div>
      </div>
    </div>

    <app-create-quick-cost
      id='create-cost'
      @changed='retrieveCosts'
      :organization_id='organization_id'
    />

  </div>
</template>

<script>

import CreateOrUpdate from '@/components/quick_costs/actions/create_or_update';

export default {
  components: {
    'app-create-quick-cost': CreateOrUpdate
  },
  props: {
    organization_id: {
      required: true
    }
  },
  data() {
    return {
      quick_costs: []
    }
  },
  methods: {
    retrieveCosts() {
      this.axiosGet(`/organizations/${this.organization_id}/quick_costs`).then(response => {
        this.quick_costs = response.data.quick_costs;
      })
    }
  },
  computed: {
    totalCosts() {
      return this.quick_costs.length;
    },
    limitReached() {
      return this.totalCosts >= 15;
    },
  },
  mounted() {
    this.retrieveCosts();
  }

}
</script>

<style scoped>
  .quick-cost-row {
    display: flex;
    justify-content: space-between;
    padding: 8px;
    border-width: 0 0 1px 0;
    border-style: solid;
    border-color: grey;
  }

  .quick-cost-description {
    margin-bottom: 16px;
    font-size: 0.75rem;
  }

  .quick-cost {
    display: flex;

    width: 100%;
  }

  .quick-cost-label {
    width: 20%;
    padding-right: 8px;
    display: flex;
    align-items: center
  }

  .quick-cost-value {
    width: 45%;
    padding-right: 8px;
    display: flex;
    align-items: center
  }

  .quick-cost-default {
    width: 15%;
    padding-right: 8px;
    display: flex;
    align-items: center
  }

  .quick-cost-icons {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    width: 20%;
  }

  .quick-cost-header {
    display: flex;
    padding: 8px;
    border-width: 0 0 1px 0;
    border-style: solid;
    border-color: grey;

    background-color: #f0f0f0;
  }

  .quick-cost-header-text {
    font-weight: bold;
  }

  .quick-cost-icon {
    cursor: pointer;
    margin-left: 8px;
    color: var(--main-color);
  }
</style>
