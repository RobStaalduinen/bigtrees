FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }

    trait :can_transfer do
      can_transfer { true }
    end
  end
end
