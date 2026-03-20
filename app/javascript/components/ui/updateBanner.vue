<template>
  <div v-if="updateAvailable" id="update-banner">
    <span>A new version is available.</span>
    <app-button :click="reload" text='Refresh' class='secondary' />
  </div>
</template>

<script>
const POLL_INTERVAL_MS = 5 * 60 * 1000; // 5 minutes
const MANIFEST_URL = '/packs/manifest.json';

export default {
  data() {
    return {
      updateAvailable: false,
      initialVersion: null,
      pollInterval: null
    };
  },
  async mounted() {
    this.initialVersion = await this.fetchVersion();
    this.pollInterval = setInterval(this.checkForUpdate, POLL_INTERVAL_MS);
  },
  beforeDestroy() {
    clearInterval(this.pollInterval);
  },
  methods: {
    async fetchVersion() {
      try {
        const response = await fetch(MANIFEST_URL, { cache: 'no-store' });
        const manifest = await response.json();
        return manifest['admin.js'];
      } catch {
        return null;
      }
    },
    async checkForUpdate() {
      const current = await this.fetchVersion();
      if (current && this.initialVersion && current !== this.initialVersion) {
        this.updateAvailable = true;
        clearInterval(this.pollInterval);
      }
    },
    reload() {
      window.location.reload();
    }
  }
};
</script>

<style scoped>
#update-banner {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  background-color: #fff3cd;
  color: #856404;
  padding: 8px 16px;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.15);
}
</style>
