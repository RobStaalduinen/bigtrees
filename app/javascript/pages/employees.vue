<template>
  <page-template>
    <app-header title='Employees'>
      <template v-slot:header-right>
        <a v-b-toggle.create-employee v-if='hasPermission("arborists", "create")' >
          New
        </a>
      </template>
    </app-header>

    <app-employee-list
      :employees='employees'
    ></app-employee-list>

   <app-create-employee
      id='create-employee'
      v-if='hasPermission("arborists", "create")'
    ></app-create-employee>

   <app-update-employee
      id='update-employee'
      v-if='hasPermission("arborists", "create")'
      :employee='selectedEmployee'
    >
   </app-update-employee>

    <app-update-employee-password
      id='update-employee-password'
      v-if='hasPermission("arborists", "create")'
      :employee='selectedEmployee'
    >
   </app-update-employee-password>

     <!-- <app-add-vehicle-expiration
        id='add-vehicle-expiration'
        v-if='hasPermission("arborists", "create")'
        :vehicle_id='selectedVehicle'
        :expiration='selectedExpiration'
      ></app-add-vehicle-expiration>
     -->
  </page-template>
</template>

<script>
import EventBus from '@/store/eventBus';
import List from '@/components/employees/views/list';
import CreateEmployee from '@/components/employees/actions/create';
import UpdateEmployee from '@/components/employees/actions/update';
import UpdatePassword from '@/components/employees/actions/updatePassword';
// import AddExpiration from '@/components/vehicles/actions/addExpiration';

export default {
  components: {
    'app-employee-list': List,
    'app-create-employee': CreateEmployee,
    'app-update-employee': UpdateEmployee,
    'app-update-employee-password': UpdatePassword
  },
  data() {
    return {
      employees: [],
      selectedEmployee: null
    }
  },
  methods: {
    retriveEmployees(){
      this.axiosGet('/arborists').then(response => {
        this.employees = response.data.arborists;
      })
    }
  },
  mounted() {
    this.retriveEmployees();

    EventBus.$on('EMPLOYEE_UPDATED', () => {
      this.retriveEmployees();
    })

    EventBus.$on('EDIT_EMPLOYEE', (employee) => {
      this.selectedEmployee = employee;
      this.$root.$emit('bv::toggle::collapse', 'update-employee');
    })

    EventBus.$on('EDIT_EMPLOYEE_PASSWORD', (employee) => {
      this.selectedEmployee = employee;
      this.$root.$emit('bv::toggle::collapse', 'update-employee-password');
    })

    // EventBus.$on('EDIT_VEHICLE_EXPIRATION', (expiration) => {
    //   this.editExpiration(expiration);
    // })
  }
}
</script>

<style scoped>

</style>
