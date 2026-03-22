FactoryBot.define do
  factory :invoice do
    association :estimate
  end
end
