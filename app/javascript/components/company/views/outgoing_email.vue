<template>
  <div>
    <app-header title='Outgoing Email' />

    <div class="email-intro">
      <p>
        Connect a Google or Microsoft email account and we will send emails from your
        real inbox on your behalf. That keeps every message with your customers in one
        place, and means your customers receive quotes and invoices from an address
        they already trust.
      </p>

      <app-button
        v-if="!nylasAccount"
        text="Connect Account"
        :click="connectAccount"
        variant="primary"
        class="email-connect-button"
      />

      <div class="email-intro-note">
        <h5>Connecting a Google account</h5>
        <ul>
          <li>
            You can safely continue past the &ldquo;Unverified app&rdquo; screen &mdash; we are
            in the process of verifying with Google.
          </li>
          <li>
            Be sure to tick the permission for <strong>sending email</strong>. Without it we
            cannot send quotes and invoices for you.
          </li>
        </ul>
      </div>
    </div>

    <div v-if="nylasAccount" class="email-info-container">
      <h4>Attached Account</h4>
      <div class="email-info">
        <div>{{ nylasAccount.outgoing_email_address }}</div>
        <div class="status-badge" :class="nylasAccount.status">
          {{ nylasAccount.status }}
        </div>
      </div>
      <div class="email-actions">
        <app-button text="Disconnect Account" :click="disconnectAccount" class="secondary" />
        <app-button text="Refresh Account" :click="connectAccount" class="primary" />
      </div>
    </div>



  </div>
</template>

<script>

  export default {
    data() {
      return {
        company: this.$store.state.organization,
      }
    },
    computed:{
      nylasAccount() {
        return this.$store.state.organization.nylas_account;
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

  .status-badge.insufficient {
    background-color: var(--warning);
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

  .email-intro {
    margin-bottom: var(--space-4);
    color: var(--text);
    font-size: var(--text-base);
    line-height: 1.5;
  }

  .email-intro p {
    margin-bottom: var(--space-3);
  }

  .email-connect-button {
    padding: var(--space-2) var(--space-4);
    font-size: var(--text-base);
    margin-bottom: var(--space-4);
  }

  .email-intro-note {
    border-left: 3px solid var(--color-brand);
    background-color: var(--color-brand-wash);
    border-radius: var(--radius-sm);
    padding: var(--space-3) var(--space-4);
  }

  .email-intro-note h5 {
    font-size: var(--text-base);
    color: var(--ink);
    margin-bottom: var(--space-2);
  }

  .email-intro-note ul {
    margin-bottom: 0;
    padding-left: var(--space-4);
  }

  .email-intro-note li + li {
    margin-top: var(--space-1);
  }
</style>