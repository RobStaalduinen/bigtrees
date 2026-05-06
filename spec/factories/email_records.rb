FactoryBot.define do
  factory :email_record do
    association :estimate
    association :arborist
    association :organization
    template_key { 'quote_mailout' }
    recipient_email { 'customer@example.com' }
    nylas_message_id { SecureRandom.uuid }
    sent_at { Time.current }
  end
end
