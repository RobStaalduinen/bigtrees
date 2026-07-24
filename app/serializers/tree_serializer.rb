# frozen_string_literal: true

# == Schema Information
#
# Table name: trees
#
#  id            :integer          not null, primary key
#  estimate_id   :integer
#  work_type     :integer          default("removal")
#  sequence      :integer          default(0)
#  cost          :decimal(10, )
#  notes         :string(255)
#  description   :string(255)
#  stump_removal :boolean
#  in_backyard   :boolean          default(FALSE)
#  job_type      :string(255)
#
class TreeSerializer < ApplicationSerializer
  attribute :description
  attribute :stump_removal
  attribute :in_backyard
  attribute :job_type
  # Raw enum value (e.g. "removal") so the edit form can pre-select the type.
  attribute :work_type

  # Virtual
  attribute :work_name
  attribute :formatted_job_type
  # Core work-type label without the "+ Stump Removal" suffix that work_name
  # adds — stump removal is surfaced as its own pill on the task card.
  attribute :work_type_name do
    object.work_type&.capitalize&.gsub("_", " ")
  end
end
