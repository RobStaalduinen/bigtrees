FactoryBot.define do
  factory :email_insertable do
    association :organization
    sequence(:key) { |n| "INSERTABLE_#{n}" }
    label { 'Add Schedule Text' }
  end
end
