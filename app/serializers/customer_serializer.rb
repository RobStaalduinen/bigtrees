# frozen_string_literal: true

class CustomerSerializer < ApplicationSerializer
  attribute :name
  attribute :email
  attribute :phone

  belongs_to :address
end
