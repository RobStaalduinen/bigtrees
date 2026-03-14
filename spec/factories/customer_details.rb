FactoryBot.define do
  factory :customer_detail do
    association :estimate
    sequence(:name) { |n| "Detail Name #{n}" }
    sequence(:email) { |n| "detail#{n}@example.com" }
    phone { "555-5678" }
  end
end
