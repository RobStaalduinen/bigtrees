# frozen_string_literal: true

class EquipmentRequestSerializer < ApplicationSerializer
  attribute :state
  attribute :category
  attribute :description
  attribute :submitted_at
  attribute :image_path
  attribute :resolution_notes

  belongs_to :vehicle
  belongs_to :arborist
  belongs_to :mechanic
end
