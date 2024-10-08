# frozen_string_literal: true

module SingleAddressable
  extend ActiveSupport::Concern

  included do
    has_one :address, as: :addressable, dependent: :destroy

    accepts_nested_attributes_for :address
  end
end
