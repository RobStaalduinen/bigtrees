# frozen_string_literal: true

module Roles
  ROLE_INDEX = {
    arborist: 'Roles::Arborist',
    team_lead: 'Roles::TeamLead',
    admin: 'Roles::Admin',
    mechanic: 'Roles::Mechanic'
  }.freeze

  def self.for_name(name)
    ROLE_INDEX[name.to_sym]&.constantize&.new&.all_permissions&.with_indifferent_access
  end
end
