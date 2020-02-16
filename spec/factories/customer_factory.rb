FactoryBot.define do
  factory :customer do
    name                  { 'Max Power' }
    email                 { 'test@email.com' }
    phone                 { '111-222-3333' }
    preferred_contact     { 'email' }

  end
end
