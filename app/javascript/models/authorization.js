class Authorization {
  constructor(role_permissions){
    this.role_permissions = role_permissions
  }

  canList(page) {
    return this.hasPermission(page, 'list')
  }

  canShow(page) {
    return this.hasPermission(page, 'show')
  }

  canUpdate(page) {
    return this.hasPermission(page, 'update')
  }

  canDelete(page) {
    return this.hasPermission(page, 'delete')
  }

  canAdmin(page) {
    return this.hasPermission(page, 'admin')
  }

  hasPermission(page, permission_type) {
    return this.role_permissions[page] && this.role_permissions[page][permission_type]
  }
}

export default Authorization
