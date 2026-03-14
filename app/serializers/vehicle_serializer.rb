# frozen_string_literal: true

# == Schema Information
#
# Table name: vehicles
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  organization_id :integer
#
class VehicleSerializer < ApplicationSerializer
  attribute :name

  has_many :expirations
end
