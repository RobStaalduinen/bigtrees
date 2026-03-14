# == Schema Information
#
# Table name: customers
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  email             :string(255)
#  phone             :string(255)
#  preferred_contact :string(255)
#  address_id        :integer
#  short_name        :string(255)
#
FactoryBot.define do
  factory :customer do
    name                  { 'Max Power' }
    email                 { 'test@email.com' }
    phone                 { '111-222-3333' }
    preferred_contact     { 'email' }

  end
end
