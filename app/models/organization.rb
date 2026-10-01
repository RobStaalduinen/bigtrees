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
  has_many :email_insertables
  has_many :estimates
  has_many :quick_costs
  has_many :tags
  has_many :receipts
  has_many :work_records

  has_one :nylas_account, dependent: :destroy

  # Association is named for the thing it holds (a set of settings) while the
  # model stays singular and idiomatic, hence the explicit class_name.
  has_one :quote_settings, class_name: 'QuoteSetting', dependent: :destroy

  def arborists_count
    arborists.active.count
  end

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

  # Only ever a 3- or 6-digit hex colour. This value is interpolated into a
  # style attribute on the quote PDF and is editable from the admin UI, so it
  # is validated at the point of use rather than trusted — anything else falls
  # back to the stylesheet's own colour.
  HEX_COLOUR = /\A#(\h{3}|\h{6})\z/

  def quote_accent_colour
    primary_colour.to_s.strip.presence&.match?(HEX_COLOUR) ? primary_colour.strip : nil
  end

  # The quote footer's fine print. One implementation, three callers: the PDF
  # footer, the backfill migration, and the fallback for organizations with no
  # quote_settings record — so none of them can drift apart.
  def default_quote_footer_text
    insurance = [
      insurance_provider,
      insurance_policy_number.present? ? "policy #{insurance_policy_number}" : nil,
      insurance_description
    ].compact_blank

    parts = []
    parts << "Insured with #{insurance.join(', ')}" if insurance.any?
    parts << "HST #{hst_number}" if hst_number.present?
    parts.join('   ')
  end

  # What the PDF actually prints: the organization's own text once set,
  # otherwise the insurance/HST line it has always shown.
  def quote_footer_text
    quote_settings&.footer_text.presence || default_quote_footer_text
  end

  # Editable page copy. Nil means the organization has never customised it, so
  # they track the stock wording — see the migration for why that beats baking
  # a copy into every row.
  def quote_pre_job_html
    expand_quote_macros(quote_settings&.pre_job_content.presence || QuoteContentDefaults::PRE_JOB)
  end

  def quote_terms_html
    expand_quote_macros(quote_settings&.terms_content.presence || QuoteContentDefaults::TERMS)
  end

  # Matches the macro convention the email templates use, so an organization
  # that renames itself sees it flow through copy it has not edited.
  def expand_quote_macros(html)
    html.to_s.gsub(QuoteContentDefaults::ORGANIZATION_MACRO, name.to_s)
  end

  # Quote PDF page toggles. No record means "include everything", which is how
  # quotes behaved before these settings existed — so organizations that never
  # open the Quote Customization screen are unaffected.
  def include_quote_image_page?
    quote_settings.nil? || quote_settings.include_image_page?
  end

  def include_quote_pre_job_page?
    quote_settings.nil? || quote_settings.include_pre_job_page?
  end

  def include_quote_terms?
    quote_settings.nil? || quote_settings.include_terms?
  end

  def configured_features
    templates = YAML.load_file(Rails.root.join('app', 'configuration_templates.yml'))

    templates.each_with_object({}) do |(name, config), hash|
      hash[name] = config['default']
    end.merge(configuration || {})
  end

  def notification_enabled?(notification)
    return false if notification.blank?

    return true if configured_notifications[notification.to_s]

    false
  end

  def parsed_notification_configuration
    value = notification_configuration
    value.is_a?(String) ? JSON.parse(value) : (value || {})
  end

  def configured_notifications
    templates = YAML.load_file(Rails.root.join('app', 'notification_templates.yml'))

    templates.each_with_object({}) do |(name, config), hash|
      hash[name] = config['default']
    end.merge(parsed_notification_configuration)
  end
end
