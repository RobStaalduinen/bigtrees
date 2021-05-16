# frozen_string_literal: true

module Roles
  class Base < Core

    def universal_permissions
      {
        documents: permission_set(list: true, show: true, create: true, update: true, delete: true),
        hours: permission_set(list: true, show: true, update: true)
      }
    end

    def role_permissions
      {}
    end

    def all_permissions
      universal_permissions.merge(role_permissions)
    end
  end
end
