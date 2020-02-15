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
