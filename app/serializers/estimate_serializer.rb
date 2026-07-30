# frozen_string_literal: true

# == Schema Information
#
# Table name: estimates
#
#  id                      :integer          not null, primary key
#  tree_quantity           :integer          default(1)
#  street                  :string(255)
#  city                    :string(255)
#  stump_removal           :boolean          default(FALSE)
#  vehicle_access          :boolean          default(FALSE)
#  breakables              :boolean          default(FALSE)
#  wood_removal            :boolean          default(FALSE)
#  status                  :integer          default("needs_costs"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  submission_completed    :boolean          default(FALSE)
#  quote_sent_date         :date
#  quote_accepted_date     :date
#  work_start_date         :date
#  extra_cost              :decimal(10, )
#  extra_cost_notes        :string(255)
#  arborist_id             :integer
#  cancelled_at            :date
#  stumping_only           :boolean          default(FALSE)
#  access_width            :string(255)
#  is_unknown              :boolean          default(FALSE)
#  customer_id             :integer
#  picture_request_sent_at :date
#  followup_sent_at        :datetime
#  work_end_date           :date
#  work_completion_date    :date
#  skip_schedule           :boolean
#  organization_id         :integer
#  pending_permit          :boolean          default(FALSE)
#  site_visit              :boolean          default(FALSE)
#  state                   :string(255)      default("in_progress"), not null
#  state_reason            :string(255)
#  approved                :boolean          default(FALSE)
#
class EstimateSerializer < ApplicationSerializer

  attribute :state
  attribute :state_reason
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
  attribute :site_visit

  attribute :created_at
  attribute :updated_at

  # Virtual
  attribute :formatted_status
  attribute :additional_message
  attribute :total_cost
  attribute :hst
  attribute :total_cost_with_tax
  attribute :site_visit_required
  attribute :work_complete

  # Cross-org transfer provenance. Kept lightweight (the linked quote lives in a
  # different org and isn't in this request's scope) — just enough to render a
  # "Transferred From / To {org}" line on the quote page.
  attribute :transferred_from
  attribute :transferred_to

  def transferred_from
    transfer_link(object.transferred_from)
  end

  def transferred_to
    transfer_link(object.transferred_to)
  end

  # Associations
  belongs_to :arborist
  belongs_to :customer
  has_one :site, include_nested_associations: true
  has_one :invoice
  has_one :customer_detail
  has_many :jobs
  has_many :costs
  has_many :trees
  has_many :tree_images
  has_many :vehicles
  has_many :notes
  has_many :tags

  private

  def transfer_link(estimate)
    return nil unless estimate

    {
      id: estimate.id,
      organization_name: estimate.organization&.name,
      state: estimate.state
    }
  end
end
