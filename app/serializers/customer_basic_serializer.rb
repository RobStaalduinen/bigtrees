# frozen_string_literal: true

class CustomerBasicSerializer < ApplicationSerializer
  attribute :name
  attribute :email
  attribute :phone
  attribute :priority

  attribute :address do
    object.formatted_address
  end
end
