<template>
  <div>
    <app-collapsable id='hours-collapse'>
      <template v-slot:title>
        <b>Hours</b>
      </template>

      <template v-slot:content>
        <div v-if='!hasHours()'>
          No hours for the past 10 days
        </div>
        <div v-else>
          <span>Last 10 Days</span>

          <table class='hour-table'>
            <tr v-for='hour in hours' :key='hour.id' class='hour-row'>
              <td>
                <b>{{ hour.date }}</b>
              </td>

              <td>
                {{ hour.range_string }}
              </td>

              <td>
                {{ hour.hours}}
              </td>
            </tr>
          </table>
        </div>

        <div class='single-estimate-link-row'>
          <div class='single-estimate-link' v-b-toggle.update-hours>
            Submit Hours
          </div>
        </div>
      </template>
    </app-collapsable>

    <app-update-hours id='update-hours'></app-update-hours>
  </div>
</template>

<script>
import UpdateHours from '@/components/hours/actions/update';

export default {
  props: {
    hours: {
      default: () => { return [] }
    }
  },
  components: {
    'app-update-hours': UpdateHours
  },
  methods: {
    hasHours() {
      return this.hours.length > 0;
    }
  }
}
</script>

<style scoped>
  .hour-table {
    width: 100%;
    margin-top: 8px;
  }

  .hour-row{
    width: 100%;
  }

  .hour-row:nth-child(odd){
    background-color: #f2f2f2;
  }

  .hour-row td {
    padding: 4px;
  }
</style>
