# frozen_string_literal: true

# == Schema Information
#
# Table name: costs
#
#  id          :integer          not null, primary key
#  estimate_id :integer
#  amount      :float(24)
#  description :string(255)
#  discount    :boolean          default(FALSE)
#
class CostSerializer < ApplicationSerializer
  attribute :amount
  attribute :description
  attribute :discount
end
