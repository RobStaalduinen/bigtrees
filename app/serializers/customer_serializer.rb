# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  email             :string(255)
#  phone             :string(255)
#  preferred_contact :string(255)
#  address_id        :integer
#  short_name        :string(255)
#  priority          :integer          default(3), not null
#
class CustomerSerializer < ApplicationSerializer
  attribute :name
  attribute :email
  attribute :phone
  attribute :priority

  attribute :recent_estimate_id

  attribute :customer_address, if: -> { instance_options[:include_addresses] }
  attribute :site_address, if: -> { instance_options[:include_addresses] }

  has_one :address
end
