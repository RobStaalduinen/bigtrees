# frozen_string_literal: true

class EstimateListSerializer < ApplicationSerializer

  attribute :state
  attribute :status
  attribute :difficulty
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

  # Lightweight flag so the list can show an image indicator without shipping
  # the full tree_images payload. Uses the eager-loaded association (no N+1).
  attribute :has_images do
    object.tree_images.any?
  end

  # Most recent email sent to the customer (from the email_records association,
  # eager-loaded in the controller so this stays in-memory / no N+1).
  attribute :last_email do
    record = object.email_records.max_by(&:sent_at)
    { template_key: record.template_key, sent_at: record.sent_at } if record
  end

  # Associations
  belongs_to :arborist, serializer: ArboristListSerializer

  belongs_to :customer, serializer: CustomerBasicSerializer

  has_many :tags
  
  has_one :site, include_nested_associations: true
  has_one :customer_detail, serializer: CustomerDetailListSerializer
end
