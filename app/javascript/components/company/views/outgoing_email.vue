<template>
  <div>
    <app-header title='Outgoing Email' />

    <span>Connect an Gmail account to use as your primary outgoing email.</span>

    <app-button text="Connect Account" :click="connectAccount" class="primary" />



  </div>
</template>

<script>

  export default {
    data() {
      return {
        company: this.$store.state.organization,
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
      }
    },
  }
</script>