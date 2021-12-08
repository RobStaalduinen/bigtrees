<template>
  <div>
    <div v-for='employee in employees' :key='employee.id' class='employee-wrapper'>
      <app-single-employee
        :employee='employee'
      />
    </div>
  </div>
</template>

<script>
import SingleListItem from './singleListItem';

export default {
  components: {
    'app-single-employee': SingleListItem
  },
  props: {
    employees: {
      type: Array,
      required: true
    }
  }
}
</script>

<style>
  .employee-wrapper {
    margin-bottom: 8px;
  }
</style>
