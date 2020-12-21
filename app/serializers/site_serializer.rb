# frozen_string_literal: true

class SiteSerializer < ApplicationSerializer
  attribute :wood_removal
  attribute :vehicle_access
  attribute :breakables
  attribute :cleanup
  attribute :low_access_width

  belongs_to :address
end
