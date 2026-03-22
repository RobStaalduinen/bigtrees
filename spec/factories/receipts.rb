FactoryBot.define do
  factory :receipt do
    association :organization
    association :arborist
    date { Date.today }
    category { 'fuel' }
    description { 'Test receipt' }
    cost { 50.0 }
    payment_method { 'Corporate Card' }
  end
end
