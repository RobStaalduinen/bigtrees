# frozen_string_literal: true

# == Schema Information
#
# Table name: email_insertables
#
#  id              :bigint           not null, primary key
#  organization_id :bigint
#  key             :string(255)      not null
#  label           :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class EmailInsertable < ActiveRecord::Base
  belongs_to :organization
  has_many :options, -> { order(:position, :id) },
           class_name: 'EmailInsertableOption',
           dependent: :destroy

  KEY_FORMAT = /\A[A-Z][A-Z0-9_]*\z/.freeze

  before_validation :normalize_key

  validates :key, presence: true,
                  format: { with: KEY_FORMAT, message: 'must be uppercase letters, numbers and underscores' },
                  uniqueness: { scope: :organization_id }
  validates :label, presence: true

  validate :key_not_reserved

  def placeholder
    "[#{key}]"
  end

  private

  def normalize_key
    self.key = key.to_s.strip.delete('[]').upcase
  end

  def key_not_reserved
    return if key.blank?

    errors.add(:key, 'is reserved') if EmailTemplate::RESERVED_KEYS.include?(key)
  end
end
