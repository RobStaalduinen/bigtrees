FactoryBot.define do
  factory :expiration do
    association               :vehicle
    name                      { Expiration::NAMES.first }
    date                      { Date.today + 1.month }
  end
end
