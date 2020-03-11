FactoryBot.define do
  factory :equipment_request do
    association             :vehicle
    category                { 'other' }
    description             { 'Test request' }
    state                   { 'submitted' }
  end
end
