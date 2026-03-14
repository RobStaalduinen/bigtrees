# == Schema Information
#
# Table name: expirations
#
#  id         :integer          not null, primary key
#  vehicle_id :integer
#  name       :string(255)
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :expiration do
    association               :vehicle
    name                      { Expiration::NAMES.first }
    date                      { Date.today + 1.month }
  end
end
