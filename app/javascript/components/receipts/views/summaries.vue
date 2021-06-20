<template>
  <section>
    <app-collapsable id='unpaid-collapse'>
      <template v-slot:title>
        <b>Total Unpaid: </b> &nbsp; {{ totalUnpaid | currency }} {{ " - " + employeeNames.length + " employees" }}
      </template>

      <template v-slot:content>
        <table>
        <tr v-for='employee in employeeNames' :key='employee'>
          <td class='employee-cell'><b>{{ employee }}</b></td>
          <td class='employee-cell'>{{ currentSummaries[employee] | currency }}</td>
        </tr>
        </table>

        <div class='collapsed-action-row'>
          <div class='collapsed-action-link' @click='approveAll'>
            <span class='collapsed-action-link-content'>Mark all as Repaid</span>
            <b-icon icon='check-circle' class='app-icon'></b-icon>
          </div>
        </div>
      </template>
    </app-collapsable>
  </section>
</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  props: {
    summaries: {
      required: true
    }
  },
  data() {
    return {
      currentSummaries: this.summaries
    }
  },
  computed: {
    employeeNames() {
      return Object.keys(this.currentSummaries);
    },
    totalUnpaid() {
      return this.employeeNames.reduce((sum, key) => { return sum + parseFloat(this.currentSummaries[key] || 0) }, 0)
    }
  },
  methods: {
    approveAll() {
      let shouldApprove = confirm('Do you want to mark ALL pending receipts as repaid?');

      if(!shouldApprove) {
        return;
      }

      this.axiosPost(`/receipts/approve_all`).then(response => {
        EventBus.$emit('RECEIPT_UPDATED');
      })
    }
  },
  watch: {
    summaries() {
      this.currentSummaries = this.summaries;
    }
  }
}
</script>

<style scoped>
  .employee-cell {
    padding: 4px;
  }
</style>
