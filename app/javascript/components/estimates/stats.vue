<template>
  <div class="stats-container">
    <div v-for="(value, key) in stats" :key="key" class="stat-item">
      <span class="stat-label">{{ labelFor(key) }}</span>
      <span class="stat-value">{{ value }}</span>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    filters: {
      type: Object,
      default: () => ({})
    },
    searchTerm: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      stats: {},
      labelMap: {
        quoting: 'Quoting',
        quote_sent: 'Sent',
        approved: 'Approved',
        scheduled: 'Scheduled',
        working: 'Working',
        invoice_sent: 'Invoiced'
      }
    }
  },
  methods: {
    labelFor(key) {
      return this.labelMap[key] ||
        key.replace(/_/g, ' ').split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
    },
    fetchStats() {
      var params = {
          created_after: this.filters.createdAfter,
          status: this.filters.status,
          assigned_to: this.filters.assignedTo || 'everyone',
          tag_ids: this.filters.tagIds || []
        }
      console.log('Search Term:', this.searchTerm);

      if (this.searchTerm != null) {
        params['q'] = this.searchTerm;
      }

      this.axiosGet('/estimates/stats', params)
        .then(response => {
          console.log('Fetched stats:', response.data);
          this.stats = response.data;
        })
        .catch(error => {
          console.error('Error fetching stats:', error);
        });
    }
  },
  mounted() {
    this.fetchStats();
  },
  watch: {
    filters: {
      deep: true,
      handler() {
        this.fetchStats();
      }
    },
    searchTerm(newTerm, oldTerm) {
      if (newTerm !== oldTerm) {
        this.fetchStats();
      }
    }
  }
}
</script>


<style scoped>
.stats-container {
  display: flex;
  border: 1px solid #e6e6e6;
  border-radius: 10px;
  overflow: hidden;
  background-color: #fff;
}

.stat-item {
  flex: 1 1 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 6px 4px;
  border-left: 1px solid #f0eeee;
}

.stat-item:first-child {
  border-left: none;
}

.stat-label {
  font-size: 9.5px;
  color: #888;
  text-transform: uppercase;
  letter-spacing: 0.02em;
  line-height: 1.15;
}

.stat-value {
  font-size: 19px;
  font-weight: 800;
  color: var(--main-color);
  line-height: 1.1;
  margin-top: 2px;
}
</style>
