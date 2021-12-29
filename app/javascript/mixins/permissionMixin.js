export default {
  methods: {
    hasPermission(page, permissionType) {
      return this.$store.getters.hasPermission(page, permissionType);
    },
    userRole(){
      return this.$store.getters.userRole();
    }
  }
}
