# frozen_string_literal: true

class AddressSerializer < ApplicationSerializer
  attribute :street
  attribute :city
  attribute :postal_code

  # Virtual
  attribute :full_address
end
