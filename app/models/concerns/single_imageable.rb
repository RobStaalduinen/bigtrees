# frozen_string_literal: true

module SingleImageable
  extend ActiveSupport::Concern

  included do
    has_one :image, as: :imageable, dependent: :destroy

    accepts_nested_attributes_for :image
  end
end
