# frozen_string_literal: true

class EstimateListSerializer < ApplicationSerializer

  attribute :state
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
  attribute :site_visit_required

  # Associations
  belongs_to :arborist

  belongs_to :customer, serializer: CustomerListSerializer

  has_many :tags
  
  has_one :site, include_nested_associations: true
  has_one :customer_detail, serializer: CustomerDetailListSerializer
end
