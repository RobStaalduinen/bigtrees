# frozen_string_literal: true

class Tag < ActiveRecord::Base
  belongs_to :organization
  has_many :taggings, dependent: :destroy

  def self.create_default(organization)
    organization.tags.create(label: "Site Visit", system: true, colour: '#c9b91e')
    organization.tags.create(label: "Pending Permit", system: true, colour: '#6b0b1c')
  end
end