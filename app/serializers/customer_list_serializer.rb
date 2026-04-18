# frozen_string_literal: true

class CustomerListSerializer < ApplicationSerializer
  attribute :name
  attribute :email
  attribute :phone
  attribute :estimate_count
  attribute :recent_estimate_id

  attribute :address do
    object.formatted_address
  end

  attribute :last_estimate_status
  attribute :last_activity_date
end
