FactoryBot.define do
  factory :work_record do
    association :organization
    association :arborist
    date { Date.today }
    hours { 8 }
  end
end
