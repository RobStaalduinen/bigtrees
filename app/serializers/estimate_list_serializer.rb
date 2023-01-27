# frozen_string_literal: true

class EstimateListSerializer < ApplicationSerializer

  attribute :status
  attribute :quote_sent_date
  attribute :quote_accepted_date
  attribute :work_start_date
  attribute :work_end_date
  attribute :is_unknown

  attribute :picture_request_sent_at
  attribute :followup_sent_at
  attribute :skip_schedule

  attribute :created_at
  attribute :updated_at

  # Virtual
  attribute :formatted_status
  attribute :additional_message

  # Associations
  belongs_to :arborist
  belongs_to :customer
  has_one :site, include_nested_associations: true
  has_one :invoice
  has_one :customer_detail
  has_many :trees
end
