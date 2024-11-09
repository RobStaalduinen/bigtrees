# frozen_string_literal: true

class EstimateSerializer < ApplicationSerializer

  attribute :status
  attribute :quote_sent_date
  attribute :quote_accepted_date
  attribute :work_start_date
  attribute :work_end_date
  attribute :is_unknown

  attribute :picture_request_sent_at
  attribute :followup_sent_at
  attribute :skip_schedule
  attribute :site_visit_tag

  attribute :created_at
  attribute :updated_at

  # Virtual
  attribute :formatted_status
  attribute :additional_message
  attribute :total_cost
  attribute :hst
  attribute :total_cost_with_tax
  attribute :site_visit_required

  # Associations
  belongs_to :arborist
  belongs_to :customer
  has_one :site, include_nested_associations: true
  has_one :invoice
  has_one :customer_detail
  has_many :costs
  has_many :trees
  has_many :tree_images
  has_many :vehicles
  has_many :notes
end
