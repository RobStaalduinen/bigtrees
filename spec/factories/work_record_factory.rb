FactoryBot.define do
  factory :work_record do
    association     :arborist
    date            { Date.today }
    start_at        { Date.today.beginning_of_day + 8.hours }
    end_at          { Date.today.beginning_of_day + 16.hours }
    hours           { 4 }

    factory :invalid_work_record do
      date          { nil }       
    end
  end
end
