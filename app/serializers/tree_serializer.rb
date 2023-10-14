# frozen_string_literal: true

class TreeSerializer < ApplicationSerializer
  attribute :description
  attribute :stump_removal
  attribute :job_type

  # Virtual
  attribute :work_name
  attribute :formatted_job_type

  has_many :tree_images
end
