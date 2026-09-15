# == Schema Information
#
# Table name: email_templates
#
#  id              :bigint           not null, primary key
#  organization_id :bigint
#  key             :string(255)
#  subject         :string(255)
#  content         :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  category        :string(255)      default("default"), not null
#
class EmailTemplate < ActiveRecord::Base
  belongs_to :organization

  KEYS = {
    quote_mailout: 'quote_mailout'
  }

  CATEGORIES = %w[default followup scheduling].freeze
  USER_MANAGED_CATEGORIES = %w[followup scheduling].freeze

  # Placeholders substituted by the client-side mailer (organizationEstimateMailer.js) or by
  # #parsed_subject. An EmailInsertable may not claim any of these as its key.
  # ADDITIONAL_CONTENT_SLOT is retired in favour of the SCHEDULE_TEXT insertable but stays
  # reserved so it cannot be re-registered.
  RESERVED_KEYS = %w[
    FIRST_NAME
    SIGNATURE
    TOTAL_COST
    TOTAL_COST_WITH_TAX
    ARBORIST_NOTES
    FOLLOWUP
    ORGANIZATION_NAME
    ADDITIONAL_CONTENT_SLOT
  ].freeze

  validates :key, presence: true, uniqueness: { scope: :organization_id }
  validates :category, inclusion: { in: CATEGORIES }

  def parsed_subject
    self.subject.gsub("[ORGANIZATION_NAME]", self.organization.name)
  end

  def self.slugify_title(title)
    title.to_s.downcase.strip.gsub(/[^a-z0-9]+/, '_').gsub(/\A_+|_+\z/, '')
  end
end
