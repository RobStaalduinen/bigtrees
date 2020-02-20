FactoryBot.define do
  factory :arborist do
    name                      { 'Test User' }
    email                     { 'test@user.com' }
    password                  { 'abc123' }
    password_confirmation     { 'abc123'}
    certification             { '12345' }

    factory :invalid_arborist do
      name                    { nil }
      password_confirmation   { nil }
    end

  end
end
