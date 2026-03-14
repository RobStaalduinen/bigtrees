# == Schema Information
#
# Table name: organizations
#
#  id                          :integer          not null, primary key
#  name                        :string(255)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  phone_number                :string(255)
#  website                     :string(255)
#  email                       :string(255)
#  email_author                :string(255)
#  outgoing_quote_email        :string(255)
#  quote_bcc                   :string(255)
#  email_signature             :string(255)
#  insurance_provider          :string(255)
#  insurance_policy_number     :string(255)
#  insurance_description       :string(255)
#  hst_number                  :string(255)
#  address_id                  :integer
#  short_name                  :string(255)
#  logo_url                    :string(255)
#  primary_colour              :string(255)
#  secondary_colour            :string(255)
#  condensed_logo_url          :string(255)
#  configuration               :json
#  quote_redirect_link         :string(255)
#  job_survey_questions        :json
#  completion_survey_questions :json
#  legal_name                  :string(255)
#
FactoryBot.define do
  factory :organization do
    name      { 'Test organization' }
  end
end
