# frozen_string_literal: true

module Roles
  class Mechanic < Base
    def role_permissions
      {
        hours: permission_set(list: true, show: true, update: true),
        equipment_requests: permission_set(list: true, show: true, create: true, update: true, scope_level: 'organization'),
        arborists: permission_set(show: true, update: true)
      }
    end
  end
end
