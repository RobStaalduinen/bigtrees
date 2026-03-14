# frozen_string_literal: true

# == Schema Information
#
# Table name: sites
#
#  id                :integer          not null, primary key
#  estimate_id       :integer
#  street            :string(255)
#  city              :string(255)
#  wood_removal      :boolean          default(TRUE)
#  vehicle_access    :boolean          default(FALSE)
#  breakables        :boolean          default(FALSE)
#  access_width      :string(255)
#  cleanup           :boolean          default(FALSE)
#  address_id        :integer
#  low_access_width  :boolean          default(FALSE)
#  survey_filled_out :boolean          default(FALSE)
#  visit_consent     :boolean          default(FALSE)
#  visit_times       :text(65535)
#
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
