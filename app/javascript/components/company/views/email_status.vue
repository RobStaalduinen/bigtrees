<template>
  <div v-if="unsynced || none || insufficient">
    <div class="email-status-banner unsynced">
      <span v-if="unsynced">The email account for this organization needs to be re-synced.</span>
      <span v-if="none">The outgoing email needs to be set up for this organization.</span>
      <span v-if="insufficient">The connected email account ({{ emailAddress }}) is not permitted to send email. Please reconnect it and allow the send email permission.</span>

      <span v-if="shouldLink()"><router-link to="/admin/company?section=outgoing_email">Update Outgoing Email Settings</router-link></span>
      <span v-else>Please contact your company administrator.</span>
    </div>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        emailStatus: this.$store.state.email_status,
        user: this.$store.state.user
      }
    },
    computed: {
      unsynced() {
        return this.emailStatus === 'unsynced';
      },
      none() {
        return this.emailStatus === 'none';
      },
      insufficient() {
        return this.emailStatus === 'insufficient';
      },
      emailAddress() {
        const account = this.$store.state.organization.nylas_account;

        return account ? account.outgoing_email_address : '';
      }
    },
    mounted() {
      this.refreshInterval = setInterval(() => {
      this.$store.dispatch('refreshEmailStatus').then(() => {
        this.emailStatus = this.$store.state.email_status;
      });
      }, 15000);
      console.log('Email Status:', this.emailStatus);
    },
    beforeDestroy() {
      clearInterval(this.refreshInterval);
    },
    methods: {
      shouldLink() {
        return this.user && this.user.role && this.user.role.includes('admin');
      }
    }
  }
</script>

<style scoped>
.email-status-banner {
  background-color: #ffcccc;
  color: #a94442;
  padding: 10px;
  text-align: center;
  font-weight: bold;
}
</style>  
