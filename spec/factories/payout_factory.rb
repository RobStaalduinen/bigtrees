# == Schema Information
#
# Table name: payouts
#
#  id         :integer          not null, primary key
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :payout do
    date                      { Date.today }
  end
end
