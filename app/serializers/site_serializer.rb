# frozen_string_literal: true

class SiteSerializer < ApplicationSerializer
  attribute :wood_removal
  attribute :vehicle_access
  attribute :breakables
  attribute :cleanup
  attribute :low_access_width
  attribute :survey_filled_out
  attribute :visit_consent
  attribute :visit_times

  has_one :address
end
