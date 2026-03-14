# == Schema Information
#
# Table name: costs
#
#  id          :integer          not null, primary key
#  estimate_id :integer
#  amount      :float(24)
#  description :string(255)
#  discount    :boolean          default(FALSE)
#
FactoryBot.define do
  factory :cost do
    association         :estimate
    amount              { 100.0 }
    description         { 'This is a test cost' }

    factory :discount do
      discount      { true }
      amount        { -25.0 }
    end
  end
end
