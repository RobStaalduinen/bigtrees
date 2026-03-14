# == Schema Information
#
# Table name: work_records
#
#  id              :integer          not null, primary key
#  arborist_id     :integer
#  date            :date
#  hours           :float(24)
#  start_at        :time
#  end_at          :time
#  unpaid_hours    :float(24)
#  hourly_rate     :float(24)
#  payout_id       :integer
#  organization_id :integer
#
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
