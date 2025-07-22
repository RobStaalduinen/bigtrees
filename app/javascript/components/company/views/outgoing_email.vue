<template>
  <div>
    <app-header title='Outgoing Email' />

    <div v-if="nylasAccount" class="email-info-container">
      <h4>Attached Account</h4>
      <div class="email-info">
        <div>{{ nylasAccount.outgoing_email_address }}</div>
        <div class="status-badge" :class="{ 'active': nylasAccount.status === 'active', 'unsynced': nylasAccount.status === 'unsynced' }">
          {{ nylasAccount.status }}
        </div>
      </div>
      <div class="email-actions">
        <app-button text="Disconnect Account" :click="disconnectAccount" class="secondary" />
        <app-button text="Refresh Account" :click="connectAccount" class="primary" />
      </div>
    </div>
    <div v-else class="email-info-container">
      <span class="email-info-text">Connect an Gmail account to use as your primary outgoing email.</span>

      <div class="email-actions">
        <app-button text="Connect Account" :click="connectAccount" class="primary" />
      </div>
    </div>



  </div>
</template>

<script>

  export default {
    data() {
      return {
        company: this.$store.state.organization,
        nylasAccount: this.$store.state.organization.nylas_account,
      }
    },
    methods: {
      connectAccount() {
        this.axiosGet(`/nylas_accounts/new`).then(response => {
          if (response.data.url) {
            window.location.href = response.data.url;
          } else {
            console.error('No URL returned from server');
          }
        }).catch(error => {
          console.error('Error connecting account:', error);
        });
      },
      disconnectAccount() {
        console.log("Disconnecting account:", this.nylasAccount.id);
        this.axiosDelete(`/nylas_accounts/${this.nylasAccount.id}`).then(response => {
          if (response.status === 200) {
            console.log('Account disconnected successfully');
            this.$store.dispatch('refreshOrganization').then(() => {
              console.log(this.$store.state.organization);
              // Reset the nylasAccount data after successful disconnection
              this.nylasAccount = this.$store.state.organization.nylas_account;
            
            });
          } else {
            
          }
        }).catch(error => {
          console.error('Error disconnecting account:', error);
          
        });
      }
    },
    mounted() {
      console.log(this.company);
      console.log(this.nylasAccount);
    }
  }
</script>

<style scoped>
  .email-info-container {
    padding: 10px;
    background-color: #f9f9f9;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    margin-bottom: 20px;
  }

  .email-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .status-badge {
    padding: 5px 10px;
    border-radius: 5px;
    color: white;
  }

  .status-badge.active {
    background-color: rgb(75, 221, 75);
  }

  .status-badge.unsynced {
    background-color: rgb(248, 52, 52);
  }

  .email-actions {
    display: flex;
    gap: 10px;
    margin-top: 20px;
  }

  .email-info-text {
    color: #666;
    margin-bottom: 10px;
  }
</style>