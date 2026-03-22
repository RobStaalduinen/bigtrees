<template>
  <div class='org-stats' v-if='stats'>
    <table class='stats-table'>
      <thead>
        <tr>
          <th></th>
          <th>Total</th>
          <th>Last 14 Days</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Estimates</td>
          <td>{{ stats.estimates.total }}</td>
          <td>{{ stats.estimates.recent }}</td>
        </tr>
        <tr>
          <td>Invoices</td>
          <td>{{ stats.invoices.total }}</td>
          <td>{{ stats.invoices.recent }}</td>
        </tr>
        <tr>
          <td>Receipts</td>
          <td>{{ stats.receipts.total }}</td>
          <td>{{ stats.receipts.recent }}</td>
        </tr>
        <tr>
          <td>Work Records</td>
          <td>{{ stats.work_records.total }}</td>
          <td>{{ stats.work_records.recent }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  props: ['stats']
}
</script>

<style scoped>
  .org-stats {
    padding: 8px 12px;
  }

  .stats-table {
    width: 100%;
    font-size: 12px;
    border-collapse: collapse;
  }

  .stats-table th {
    text-align: left;
    color: #666;
    font-weight: normal;
    padding: 4px 8px 4px 0;
    border-bottom: 1px solid #eee;
  }

  .stats-table td {
    padding: 4px 8px 4px 0;
  }

  .stats-table tbody tr:not(:last-child) td {
    border-bottom: 1px solid #f5f5f5;
  }
</style>
