# frozen_string_literal: true

class OrganizationMembership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :arborist
end
