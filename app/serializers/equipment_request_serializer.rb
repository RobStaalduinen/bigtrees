# frozen_string_literal: true

class EquipmentRequestSerializer < ApplicationSerializer
  attribute :category
  attribute :description
  attribute :submitted_at
  attribute :image_path

  belongs_to :vehicle
  belongs_to :arborist
end
