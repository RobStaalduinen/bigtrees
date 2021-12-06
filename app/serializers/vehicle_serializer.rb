# frozen_string_literal: true

class VehicleSerializer < ApplicationSerializer
  attribute :name

  has_many :expirations
end
