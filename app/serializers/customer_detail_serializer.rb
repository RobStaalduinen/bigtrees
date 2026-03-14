# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_details
#
#  id          :integer          not null, primary key
#  estimate_id :integer
#  name        :string(255)
#  email       :string(255)
#  phone       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class CustomerDetailSerializer < ApplicationSerializer
  attribute :name
  attribute :email
  attribute :phone

  has_one :address
end
