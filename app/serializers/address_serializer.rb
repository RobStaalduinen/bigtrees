# frozen_string_literal: true

class AddressSerializer < ApplicationSerializer
  attribute :street
  attribute :city

  # Virtual
  attribute :full_address
end
