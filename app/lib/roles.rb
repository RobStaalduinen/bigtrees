# frozen_string_literal: true

module Roles
  ROLE_INDEX = {
    arborist: Roles::Arborist::PERMISSIONS,
    team_lead: Roles::TeamLead::PERMISSIONS,
    admin: Roles::Admin::PERMISSIONS,
    mechanic: Roles::Mechanic::PERMISSIONS
  }.freeze

  def self.for_name(name)
    ROLE_INDEX[name.to_sym]
  end
end
