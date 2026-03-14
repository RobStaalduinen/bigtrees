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
FactoryBot.define do
  factory :estimate do
    association               :customer
    association               :site
    tree_quantity             { 1 }
    submission_completed      { true }
  end
end
