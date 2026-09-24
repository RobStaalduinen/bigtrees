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

  # The management form caps an insertable at this many options; the model enforces the same
  # ceiling so the API cannot be talked past it.
  MAX_OPTIONS = 10

  accepts_nested_attributes_for :options, allow_destroy: true

  before_validation :normalize_key

  validates :key, presence: true,
                  format: { with: KEY_FORMAT, message: 'must be uppercase letters, numbers and underscores' },
                  uniqueness: { scope: :organization_id }
  validates :label, presence: true

  validate :key_not_reserved
  validate :option_count_within_limit

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

  # Counted off the association target rather than `options` so validating never loads (and so
  # never caches an empty) collection — `dependent: :destroy` reads that same target.
  # Nested attributes only put the submitted options in the target, so persisted options the
  # submission left alone are counted separately.
  def option_count_within_limit
    pending = association(:options).target
    return if pending.empty?

    untouched = new_record? ? 0 : options.where.not(id: pending.map(&:id).compact).count
    kept = pending.count { |option| !option.marked_for_destruction? }

    return if untouched + kept <= MAX_OPTIONS

    errors.add(:options, "cannot have more than #{MAX_OPTIONS}")
  end
end
