<template>
  <page-template v-if='user'>
    <app-header
      :title='user.name'
    ></app-header>

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

    <app-documents-collapsed :documents='documents'></app-documents-collapsed>
  </page-template>
</template>

<script>
import DocumentsCollapsed from '@/components/documents/views/collapsed';

export default {
  components: {
    'app-documents-collapsed' : DocumentsCollapsed
  },
  data(){
    return {
      user_id: this.$route.params.user_id,
      user: null,
      documents: null
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
    }
  },
  mounted() {
    this.retrieveUser();
    this.retrieveDocuments();
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
