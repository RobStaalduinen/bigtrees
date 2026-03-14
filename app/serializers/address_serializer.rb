# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id               :integer          not null, primary key
#  street           :string(255)
#  city             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  addressable_id   :integer
#  addressable_type :string(255)
#  postal_code      :string(255)
#
class AddressSerializer < ApplicationSerializer
  attribute :street
  attribute :city
  attribute :postal_code

  # Virtual
  attribute :full_address
end
