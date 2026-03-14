# frozen_string_literal: true

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
class Organization < ActiveRecord::Base
  include SingleAddressable

  has_many :organization_memberships, dependent: :destroy
  has_many :arborists, through: :organization_memberships
  has_many :email_templates
  has_many :estimates
  has_many :quick_costs
  has_many :tags

  has_one :nylas_account, dependent: :destroy

  def default_arborist
    arborists.where(role: ['admin', 'super_admin']).first
  end

  def quote_author
    "#{email_author} <#{outgoing_quote_email}>"
  end

  def feature_enabled?(feature)
    return false if feature.blank?

    # Check if the feature is enabled in the configuration
    return true if configured_features[feature.to_s]

    false
  end

  def configured_features
    templates = YAML.load_file(Rails.root.join('app', 'configuration_templates.yml'))

    templates.each_with_object({}) do |(name, config), hash|
      hash[name] = config['default']
    end.merge(configuration || {})
  end
end
