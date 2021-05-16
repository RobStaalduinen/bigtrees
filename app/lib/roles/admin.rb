# frozen_string_literal: true

module Roles
  class Admin < Base
    def role_permissions
      {
        hours: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true, scope_level: 'organization'),
        estimates: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: 'organization'),
        receipts: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: 'organization'),
        equipment_requests: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: 'organization'),
        arborists: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: 'organization'),
        customers: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: 'organization'),
        vehicles: permission_set(list: true, show: true, create: true, update: true, delete: true, admin: true,  scope_level: 'organization')
      }
    end
  end
end
