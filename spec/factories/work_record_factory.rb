FactoryBot.define do
  factory :work_record do
    association     :arborist
    date            { Date.today }
    hours           { 4 }

    factory :invalid_work_record do
      date          { nil }       
    end
  end
end
