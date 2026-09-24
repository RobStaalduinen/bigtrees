FactoryBot.define do
  factory :email_insertable_option do
    association :email_insertable
    sequence(:label) { |n| "Option #{n}" }
    content { 'We could take care of your job as early as the next few days.' }
    position { 0 }
  end
end
