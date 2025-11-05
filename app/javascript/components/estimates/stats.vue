<template>
  <div class="stats-container">
    <div v-for="(value, key) in stats" :key="key" class="stat-item">
      <span class="stat-label"><b>{{ key.replace(/_/g, ' ').split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ') }}:</b></span>
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
      stats: {}
    }
  },
  methods: {
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
  justify-content: space-around;
  padding: 10px;
  background-color: #f9f9f9;
  border: 1px solid #ddd;
  border-radius: 5px;
  font-size: 8pt;
}

.stat-item {
  text-align: center;
  padding: 4px;
}


</style>
