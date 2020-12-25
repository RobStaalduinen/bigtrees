# frozen_string_literal: true

class EstimateSerializer < ApplicationSerializer

  attribute :status
  attribute :quote_sent_date
  attribute :quote_accepted_date
  attribute :work_date
  attribute :is_unknown

  attribute :created_at
  attribute :updated_at

  # Virtual
  attribute :formatted_status
  attribute :additional_message
  attribute :total_cost
  attribute :hst
  attribute :total_cost_with_tax

  # Associations
  belongs_to :arborist
  belongs_to :customer
  has_one :site, include_nested_associations: true
  has_one :invoice
  has_many :costs
end
