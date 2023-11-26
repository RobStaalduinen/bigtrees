# frozen_string_literal: true

module Roles
  class Admin < Base
    def default_scope_level
      'organization'
    end

    def role_permissions
      {
        hours: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true, scope_level: default_scope_level),
        work_records: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true, scope_level: default_scope_level),
        estimates: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: default_scope_level),
        receipts: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: default_scope_level),
        equipment_requests: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: default_scope_level),
        arborists: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: default_scope_level),
        customers: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: default_scope_level),
        vehicles: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: default_scope_level)
      }
    end
  end
end
