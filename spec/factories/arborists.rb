FactoryBot.define do
  factory :arborist do
    sequence(:name) { |n| "Arborist #{n}" }
    sequence(:email) { |n| "arborist#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    role { "admin" }

    transient do
      organization { nil }
    end

    after(:create) do |arborist, evaluator|
      if evaluator.organization
        create(:organization_membership, arborist: arborist, organization: evaluator.organization)
      end
    end

    trait :admin do
      role { "admin" }
    end

    trait :arborist_role do
      role { "arborist" }
    end
  end
end
