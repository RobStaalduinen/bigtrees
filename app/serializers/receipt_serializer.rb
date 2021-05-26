# frozen_string_literal: true

class ReceiptSerializer < ApplicationSerializer
  attribute :date
  attribute :category
  attribute :job
  attribute :payment_method
  attribute :description
  attribute :cost
  attribute :state

  attribute :image_path

  # Associations
  belongs_to :arborist
end
