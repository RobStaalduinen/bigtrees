# frozen_string_literal: true

class TreeSerializer < ApplicationSerializer
  attribute :description

  # Virtual
  attribute :work_name

  has_many :tree_images
end
