FactoryBot.define do
  factory :receipt do
    association       :arborist
    date              { Date.today }
    category          { 'Fuel' }
    job               { 'Big Trees' }
    payment_method    { 'Corporate Card' }
    cost              { 100.0 }
    approved          { false }
  end
end
