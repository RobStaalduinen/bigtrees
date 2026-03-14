FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "Customer #{n}" }
    sequence(:email) { |n| "customer#{n}@example.com" }
    phone { "555-1234" }
  end
end
