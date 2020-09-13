<template>
  <tr class='record-row'>
    <td class='row-entry-lg'>{{ workRecord.arborist }}</td>
    <td class='row-entry'>{{ workRecord.start_at | localizeTimepicker }}</td>
    <td class='row-entry'>{{ workRecord.end_at | localizeTimepicker }}</td>
    <td class='row-entry-sm'>{{ workRecord.unpaid_hours }}</td>
    <td class='row-entry-sm'>{{ workRecord.hours }}</td>
    <td class='row-entry-sm entry-center' @click='toggleEdit()'><b-icon icon='pencil-square' style="color: #3489eb;"></b-icon></td>
  </tr>
</template>

<script>
export default {
  props: ['workRecord'],
  data() {
    return {
      editedRecord: {
        start_at: this.workRecord.start_at,
        end_at: this.workRecord.end_at,
        unpaidHours: this.workRecord.unpaid_hours,
      }
    }
  },
  methods: {
    toggleEdit() {
      this.$emit('editToggled', this.workRecord);
    }
  }
}
</script>

<style>
   .record-row > td {
    padding: 12px 0;
    padding-left: 4px;
  }

  .row-entry-lg{
    width: 20%;
  }

  .row-entry{
    width: 15%;
  }

  .row-entry-sm{
    width: 8%;
  }

  .entry-center{
    text-align: center;
  }

  .row-input {
    font-size: 12px !important;
    padding: 0 0 0 4px !important;
    line-height: 12px !important;
    margin-left: -4px;
  }
</style>
