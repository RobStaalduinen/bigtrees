# == Schema Information
#
# Table name: vehicles
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  organization_id :integer
#
FactoryBot.define do
  factory :vehicle do
    name                      { 'Test Vehicle' }
  end
end
