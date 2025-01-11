# frozen_string_literal: true

class CustomerSerializer < ApplicationSerializer
  attribute :name
  attribute :email
  attribute :phone

  attribute :recent_estimate_id

  attribute :customer_address, if: -> { instance_options[:include_addresses] }
  attribute :site_address, if: -> { instance_options[:include_addresses] }

  has_one :address
end
