<template>
  <!-- <b-modal :id='modalId' centered title='Filters'>
    <b-form-group
      label="Status"
      label-for="status"
    >
      <b-form-select v-model="status" :options="statusOptions" @change="changeFilters()"></b-form-select>
    </b-form-group>

    <b-form-group
      label="Estimate Age"
      label-for="created_after"
    >
      <b-form-select v-model="createdAfter" :options="createdOptions" @change="changeFilters()"></b-form-select>
    </b-form-group>

    <template v-slot:modal-footer>
      <b-button block class='submit-button' @click='close()'>Done</b-button>
    </template>
  </b-modal> -->

  <app-right-sidebar
    :id="id"
    title="Filters"
    submitText="Done"
    :onSubmit="close"
    hideCancel
  >
    <template v-slot:content>
      <div class="filter-rows">
        <div class="filter-row">
          <span class="filter-label">Sort by</span>
          <b-form-select class="filter-select" v-model="sortBy" :options="sortOptions" @change="changeFilters()" />
        </div>

        <div class="filter-row">
          <span class="filter-label">Assigned</span>
          <app-segmented-control
            :value="assignedTo"
            :options="assignedOptions"
            @input="v => selectOption('assignedTo', v)"
          />
        </div>

        <div class="filter-row">
          <span class="filter-label">Status</span>
          <b-form-select class="filter-select" v-model="status" :options="statusOptions" @change="changeFilters()" />
        </div>

        <div class="filter-row">
          <span class="filter-label">Difficulty</span>
          <app-segmented-control
            :value="difficulty"
            :options="difficultyOptions"
            @input="v => selectOption('difficulty', v)"
          />
        </div>

        <div class="filter-row">
          <span class="filter-label">Age</span>
          <app-segmented-control
            :value="createdAfter"
            :options="createdOptions"
            @input="v => selectOption('createdAfter', v)"
          />
        </div>

        <div class="filter-row filter-row--top">
          <span class="filter-label">Tags</span>
          <app-tag-selector
            id="tag-selector"
            v-model="tagIds"
          />
        </div>
      </div>
    </template>
  </app-right-sidebar>
</template>

<script>
import TagSelector from '@/components/tags/views/selector.vue'

export default {
  components: {
    'app-tag-selector': TagSelector
  },
  props: {
    id: {
      required: true,
      type: String
    },
    value: {
      type: Object,
      default: function() {
        return {
          status: 'active',
          createdAfter: 'forever',
          tagIds: [],
          sortBy: 'date',
          difficulty: 'all'
        }
      }
    }
  },
  data() {
    return {
      sortOptions: [
        { value: 'date', text: 'Date (newest first)' },
        { value: 'priority', text: 'Priority (highest first)' },
        { value: 'difficulty_high', text: 'Difficulty (highest first)' },
        { value: 'difficulty_low', text: 'Difficulty (lowest first)' }
      ],
      difficultyOptions: [
        { value: 'all', text: 'All' },
        { value: 'easy', text: 'Easy' },
        { value: 'medium', text: 'Med' },
        { value: 'hard', text: 'Hard' }
      ],
      assignedOptions: [
        { value: 'everyone', text: 'Everyone' },
        { value: 'me', text: 'Me' }
      ],
      statusOptions: [
        { value: 'all', text: 'All' },
        { value: 'active', text: 'Active' },
        { value: 'completed', text: 'Completed' },
        { value: 'on_hold', text: 'On Hold' },
        { value: 'pre_quote', text: 'Quote Needed' },
        { value: 'awaiting_response', text: 'Awaiting Customer Response' },
        { value: 'to_pay', text: 'To Pay' },
        { value: 'approved', text: 'Approved' },
        { value: 'scheduled', text: 'Scheduled' },
        { value: 'working', text: 'Working' },
        { value: 'unknown', text: 'Unknown' },
        { value: 'cancelled', text: 'Cancelled' }
      ],
      createdOptions: [
        { value: 'one_week', text: '1w' },
        { value: 'one_month', text: '1m' },
        { value: 'six_months', text: '6m' },
        { value: 'one_year', text: '1y' },
        { value: 'forever', text: 'All' }
      ],
      status: null,
      createdAfter: null,
      tagIds: [],
      assignedTo: 'everyone',
      sortBy: 'date',
      difficulty: 'all'
    }

  },
  mounted() {
    this.tagIds = this.value.tagIds || [];
    this.assignedTo = this.value.assignedTo || 'everyone';
    this.status = this.value.status;
    this.createdAfter = this.value.createdAfter;
    this.sortBy = this.value.sortBy || 'date';
    this.difficulty = this.value.difficulty || 'all';
  },
  methods: {
    close(){
      // this.$bvModal.hide(this.modalId);
      this.$root.$emit('bv::toggle::collapse', this.id);
    },
    changeFilters() {
      this.$emit('input', this.filterObject());
      // localStorage.setItem('estimateFilterStatus', JSON.stringify(this.filterObject()));
    },
    selectOption(key, value) {
      this[key] = value;
      this.changeFilters();
    },
    filterObject() {
      return { status: this.status, createdAfter: this.createdAfter, tagIds: this.tagIds, assignedTo: this.assignedTo, sortBy: this.sortBy, difficulty: this.difficulty };
    }
  },
  watch: {
    value() {
      this.status = this.value.status;
      this.createdAfter = this.value.createdAfter;
      this.tagIds = this.value.tagIds || [];
      this.assignedTo = this.value.assignedTo || 'everyone';
      this.sortBy = this.value.sortBy || 'date';
      this.difficulty = this.value.difficulty || 'all';
    },
    tagIds() {
      this.$emit('input', this.filterObject());
      console.log('Tag IDs changed:', this.tagIds);
    }
  }
}
</script>

<style scoped>
  .filter-rows {
    margin-top: 4px;
  }

  .filter-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 10px 0;
    border-bottom: 1px solid #f0f0f0;
  }

  .filter-row:last-child {
    border-bottom: none;
  }

  .filter-row--top {
    align-items: flex-start;
  }

  .filter-label {
    font-size: 13px;
    font-weight: 600;
    color: #444;
    flex: 0 0 auto;
    min-width: 74px;
  }

  .filter-row--top .filter-label {
    padding-top: 4px;
  }

  .filter-select {
    flex: 1 1 auto;
    max-width: 240px;
  }
</style>
