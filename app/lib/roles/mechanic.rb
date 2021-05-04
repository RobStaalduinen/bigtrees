# frozen_string_literal: true

module Roles
  class Mechanic < Base
    PERMISSIONS = {
      hours: permission_set(list: true, show: true, update: true),
      equipment_requests: permission_set(list: true, show: true, create: true, update: true, scope_level: 'organization'),
      arborists: permission_set(show: true, update: true)
    }.freeze
  end
end
