<template>
  <page-template v-if='user'>
    <app-header>
      <template v-slot:header-left>
        <div id='user-header'>
          <h5>{{ user.name }}</h5>

          <div id='user-contact-details'>
            <div id='user-contact-row'>
              <b-icon icon='telephone' class='contact-icon'></b-icon>
              <a :href="'tel:' + user.phone_number">{{ user.phone_number }}</a>
            </div>

            <div id='user-contact-row'>
              <b-icon icon='envelope' class='contact-icon'></b-icon>
              <a :href="'mailto:' + user.email">{{ user.email }}</a>
            </div>
          </div>
        </div>
      </template>

    </app-header>

    <section class='spaced-row'>
      <div id ='action-row'>
        <a class='action-link' v-b-toggle.update-employee>Update Personal Details</a>
        <template v-if='loggedInUser.id == user_id'>
          <span class='action-link'> | </span>
          <a class='action-link' v-b-toggle.update-password>Change Password</a>
        </template>
      </div>
    </section>

    <section class='spaced-row'>
      <app-documents-collapsed :documents='documents' :arborist_id='user_id'></app-documents-collapsed>
    </section>

    <section class='spaced-row'>
      <app-hours-collapsed :hours='hours'></app-hours-collapsed>
    </section>

   <app-update-employee
      id='update-employee'
      v-if='hasPermission("arborists", "update")'
      :employee='user'
    >
   </app-update-employee>

    <app-update-password
    v-
      id='update-password'
      :employee='user'
    >
   </app-update-password>
  </page-template>
</template>

<script>
import DocumentsCollapsed from '@/components/documents/views/collapsed';
import HoursCollapsed from '@/components/hours/views/collapsed';
import UpdatePassword from '@/components/employees/actions/updatePassword';
import UpdateEmployee from '@/components/employees/actions/update';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-documents-collapsed' : DocumentsCollapsed,
    'app-hours-collapsed': HoursCollapsed,
    'app-update-password' : UpdatePassword,
    'app-update-employee': UpdateEmployee
  },
  data(){
    return {
      user_id: this.$route.params.user_id,
      user: null,
      documents: null,
      hours: [],
      loggedInUser: this.$store.state.user
    }
  },
  methods: {
    retrieveUser() {
      this.axiosGet(`/arborists/${this.user_id}.json`)
        .then(response => {
          this.user = response.data.arborist;
        }).catch(
          (error) => {
            // this.$router.push('/admin/estimates');
          }
        )
    },
    retrieveDocuments() {
      this.axiosGet(`/arborists/${this.user_id}/documents.json`)
        .then(response => {
          this.documents = response.data.documents;
        }).catch(
          (error) => {
            // this.$router.push('/admin/estimates');
          }
        )
    },
    retrieveWorkRecords() {
      let params = { arborist_id: this.user_id}
      this.axiosGet('/work_records/for_arborist', params).then(response => {
        this.hours = response.data.work_records;
      })
    }
  },
  mounted() {
    this.retrieveUser();
    this.retrieveDocuments();
    this.retrieveWorkRecords();

    EventBus.$on('DOCUMENT_UPDATED', () => {
      this.retrieveDocuments();
    })

    EventBus.$on('WORK_RECORD_UPDATED', () => {
      this.retrieveWorkRecords();
    });

    EventBus.$on('EMPLOYEE_UPDATED', () => {
      this.retrieveUser();
    })
  }
}
</script>

<style scoped>
  #user-contact-details {
    display: flex;
    flex-direction: column;
  }

  #user-contact-row {
    display: flex;
    align-items: center;
    margin-bottom: 8px;
  }

  .contact-icon {
    color: var(--main-color);
    margin-right: 4px;
  }

  #user-header {
    display: flex;
    flex-direction: column;
    margin-bottom: -8px;
  }

  #action-row {
    display: flex;
  }

  .action-link {
    margin-right: 8px;
    cursor: pointer;
  }

  @media(min-width: 760px) {
    #user-contact-details {
      display: flex;
      flex-direction: row;
    }

    #user-contact-row {
      margin-right: 32px;
    }
  }
</style>
