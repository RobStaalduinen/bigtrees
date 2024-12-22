# frozen_string_literal: true

class QuickCostSerializer < ApplicationSerializer
  attribute :id
  attribute :label
  attribute :content
  attribute :default_cost

  attribute :created_at
end
