<template>
  <div>
    <i id='info-header'>Use negative numbers for discounts</i>

    <div class='cost-row cost-row--header'>
      <div class='col-amount'>Amount</div>
      <div class='col-description'>Invoice Description</div>
      <div class='col-action'></div>
    </div>

    <div v-for='(cost, index) in costs' :key='cost.key' class='cost-row'>
      <div class='col-amount'>
        <app-number-field
          :value='cost.amount'
          :name='`cost_${index}_amount`'
          label=''
          groupClass='mb-2'
          validationRules='required'
          @input='(value) => updateAmount(index, value)'
        ></app-number-field>
      </div>
      <div class='col-description'>
        <app-input-field
          :value='cost.description'
          :name='`cost_${index}_description`'
          label=''
          groupClass='mb-2'
          validationRules='required'
          :maxLength='65'
          @input='(value) => updateDescription(index, value)'
        ></app-input-field>
      </div>
      <div class='col-action'>
        <b-icon
          icon='trash-fill'
          class='delete-icon'
          v-if='costs.length > 1'
          @click='deleteCost(index)'/>
      </div>
    </div>

    <div id='add-cost-row' @click.prevent='addCost'>
      <span>+ Add Cost +</span>
    </div>

    <div class='costs-divider'></div>

    <app-quick-costs :addCost='addQuickCost'></app-quick-costs>
  </div>
</template>

<script>
  // Invoice line items for the new-quote form. Standalone from tasks/images:
  // a cost is just an amount + invoice description. Owns its own array (rather
  // than acting as a controlled child) so quick-cost buttons reliably append a
  // visible row. Laid out as a table — shared column headers, bare field rows —
  // so adding a cost just appends another row, not a labelled block.
  // app-number-field / app-input-field are registered globally (packs/admin.js).
  import QuickCosts from '@/components/costs/widgets/quick';

  export default {
    components: {
      'app-quick-costs': QuickCosts
    },
    data() {
      return {
        costs: [this.defaultCost()]
      }
    },
    methods: {
      defaultCost() {
        return {
          key: Math.random().toString(36).substr(2, 9),
          amount: null,
          description: null
        }
      },
      addCost() {
        this.costs.push(this.defaultCost());
        this.emit();
      },
      addQuickCost(amount, description) {
        this.costs.push({
          key: Math.random().toString(36).substr(2, 9),
          amount: amount,
          description: description
        });
        this.emit();
      },
      updateAmount(index, value) {
        this.$set(this.costs[index], 'amount', value);
        this.emit();
      },
      updateDescription(index, value) {
        this.$set(this.costs[index], 'description', value);
        this.emit();
      },
      deleteCost(index) {
        this.costs.splice(index, 1);
        this.emit();
      },
      emit() {
        this.$emit('input', this.costs);
      }
    },
    mounted() {
      this.emit();
    }
  }
</script>

<style scoped>
  #info-header {
    font-size: 14px;
  }

  .cost-row {
    display: flex;
    align-items: flex-start;
    gap: 8px;
  }

  .cost-row--header {
    font-size: 13px;
    font-weight: 600;
    color: var(--main-color);
    margin: 4px 0;
  }

  .col-amount {
    flex: 0 0 30%;
  }

  .col-description {
    flex: 1;
    min-width: 0;
  }

  .col-action {
    flex: 0 0 20px;
    display: flex;
    justify-content: center;
    align-items: center;
    padding-top: 6px;
  }

  #add-cost-row {
    width: 100%;
    display: flex;
    justify-content: center;
    color: var(--main-color);
    font-size: 18px;
    margin-top: 0;
    cursor: pointer;
  }

  .costs-divider {
    border-top: 1px solid gray;
    margin-top: 8px;
  }

  .delete-icon {
    color: var(--main-color);
    cursor: pointer;
  }
</style>
