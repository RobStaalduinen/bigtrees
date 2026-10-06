FactoryBot.define do
  factory :nylas_account do
    organization

    sequence(:grant_id) { |n| "grant-#{n}" }
    sequence(:outgoing_email_address) { |n| "outgoing#{n}@example.com" }
    status { 'active' }
  end
end
