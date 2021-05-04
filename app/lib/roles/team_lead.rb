# frozen_string_literal: true

module Roles
  class TeamLead < Base
    PERMISSIONS = Arborist::PERMISSIONS.merge(
      {
        estimates: permission_set(list: true, show: true, update: true)
      }
    ).freeze
  end
end
