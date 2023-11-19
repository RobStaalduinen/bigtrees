# frozen_string_literal: true

module Roles
  class SuperAdmin < Roles::Admin
    def default_scope_level
      'all'
    end

    def role_permissions
      super.merge(
        {
          organizations: permission_set(list: true, show: true, create: true, update: true, admin: true, scope_level: default_scope_level)
        }
      )
    end
  end
end
