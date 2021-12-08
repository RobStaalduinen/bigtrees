# frozen_string_literal: true

class ArboristSerializer < ApplicationSerializer
  attribute :name
  attribute :email
  attribute :phone_number
  attribute :role
  attribute :certification
  attribute :hourly_rate
end
