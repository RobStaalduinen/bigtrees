# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_memberships
#
#  id              :bigint           not null, primary key
#  organization_id :bigint
#  arborist_id     :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  hourly_rate     :float(24)        default(0.0)
#
class OrganizationMembership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :arborist
end
