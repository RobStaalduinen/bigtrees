# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id              :bigint           not null, primary key
#  organization_id :bigint
#  label           :string(255)      not null
#  colour          :string(255)      not null
#  system          :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Tag < ActiveRecord::Base
  belongs_to :organization
  has_many :taggings, dependent: :destroy

  def self.create_default(organization)
    organization.tags.create(label: "Site Visit", system: true, colour: '#c9b91e')
    organization.tags.create(label: "Pending Permit", system: true, colour: '#6b0b1c')
  end
end
