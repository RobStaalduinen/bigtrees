export default {
  methods: {
    hasPermission(page, permissionType) {
      return this.$store.getters.hasPermission(page, permissionType);
    },
    featureEnabled(feature) {
      return this.$store.getters.featureEnabled(feature);
    },
    userRole(){
      return this.$store.getters.userRole();
    }
  }
}
