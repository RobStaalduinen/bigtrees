<template>
  <div>
  <app-header title='Settings' />

    <div class='settings-list'>
      <div class='settings-row' v-for='setting in settings'>
        <div class='settings-left'>
          <div class='settings-header'>{{ formatName(setting.name) }}</div>
          <div class='settings-description'>{{ setting.description }}</div>
        </div>
        <div class='settings-right'>
          <toggle-button v-model="setting.value" class="settings-toggle" @change="updateSetting(setting.name, setting.value)"/>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      company: this.$store.state.organization,
      settings: []
    }
  },
  methods: {
    retrieveSettings() {
      this.axiosGet(`/organizations/${this.company.id}/configurations`).then(response => {
        this.settings = response.data;
        console.log(this.settings);
      })
    },
    formatName(string) {
      return string.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
    },
    updateSetting(name, value) {
      this.axiosPut(`/organizations/${this.company.id}/configurations/${name}`, { value: value }).then(response => {
        console.log(response);
      })
    }
  },
  
  mounted() {
    this.retrieveSettings();
  }
}
</script>

<style scoped>
  .settings-list {
    display: flex;
    flex-direction: column;
  }

  .settings-row {
    display: flex;
    justify-content: space-between;
    padding: 10px 0;
    border-bottom: 1px solid #ccc;
  }

  .settings-left {
    width: 70%;
  }

  .settings-header {
    font-weight: bold;
  }

  .settings-description {
    font-size: 12px;
  }

  .settings-right {
    width: 30%;
    text-align: right;
    display: flex;
    align-items: center;
    justify-content: flex-end;
  }

</style>