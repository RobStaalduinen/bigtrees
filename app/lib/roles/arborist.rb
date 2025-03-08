# frozen_string_literal: true

module Roles
  class Arborist < Base
    def role_permissions
      {
        receipts: permission_set(list: true, show: true, create: true),
        equipment_requests: permission_set(list: true, show: true, create: true, update: false),
        arborists: permission_set(list: true, show: true, update: true),
        vehicles: permission_set(list: true, show: true, create: false, update: false, delete: false, admin: false, scope_level: 'organization'),
        organizations: permission_set(list: true, show: true, create: false, update: false, delete: false, admin: false, scope_level: 'self'),
        estimates: permission_set(list: true, show: true, create: false, update: false, delete: false, admin: false, scope_level: 'organization'),
      }
    end
  end
end
