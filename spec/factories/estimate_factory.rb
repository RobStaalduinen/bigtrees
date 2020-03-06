FactoryBot.define do
  factory :estimate do
    association               :customer
    tree_quantity             { 1 }
    submission_completed      { true }
  end
end
