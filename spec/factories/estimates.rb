FactoryBot.define do
  factory :estimate do
    association :customer
    association :arborist
    association :organization

    trait :complete do
      after(:create) do |estimate|
        create(:site, estimate: estimate)
        create(:customer_detail, estimate: estimate)
      end
    end
  end
end
