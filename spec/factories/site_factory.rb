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
FactoryBot.define do
  factory :site do
    street    { 'Test Street' }
    city      { 'Test City' }
  end
end
