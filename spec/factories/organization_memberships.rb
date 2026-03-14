FactoryBot.define do
  factory :organization_membership do
    association :organization
    association :arborist
  end
end
