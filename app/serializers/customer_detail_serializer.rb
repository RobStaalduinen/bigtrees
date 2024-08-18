# frozen_string_literal: true

class CustomerDetailSerializer < ApplicationSerializer
  attribute :name
  attribute :email
  attribute :phone

  has_one :address
end
