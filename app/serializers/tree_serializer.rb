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
  attribute :job_type

  # Virtual
  attribute :work_name
  attribute :formatted_job_type
end
