# frozen_string_literal: true

module Roles
  class TeamLead < Base
    def role_permissions
      Roles::Arborist.new.role_permissions.merge(
        {
          estimates: permission_set(list: true, show: true, create: true, update: true),
          customers: permission_set(show: true, create: true, update: true),
          notes: permission_set(create: true),
        }
      )
    end
  end
end
