# frozen_string_literal: true

class ArboristSerializer < ApplicationSerializer
  attribute :name
  attribute :email
  attribute :phone_number
  attribute :can_manage_estimates
end
