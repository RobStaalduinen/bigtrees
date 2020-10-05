FactoryBot.define do
  factory :estimate do
    association               :customer
    association               :site
    tree_quantity             { 1 }
    submission_completed      { true }
  end
end
