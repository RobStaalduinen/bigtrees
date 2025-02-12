class Receipt < ActiveRecord::Base
  belongs_to :organization
  belongs_to :arborist
  belongs_to :vehicle

  scope :cheque, -> { where(category: 'Cheque' )}
  scope :regular, -> { where.not(category: 'Cheque' )}

  scope :approved, -> { where(approved: true) }
  scope :unapproved, -> { where(approved: false) }

  enum state: {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected'
  }

  CATEGORIES = ['Fuel', 'Tools', 'Repairs', 'Travel', 'Cheque', 'Other'].freeze
  DEFAULT_CATEGORY = 'Fuel'
  JOBS = ['Big Trees', 'Big Properties', 'Big Stumps'].freeze
  DEFAULT_JOB = 'Big Trees'
  PAYMENT_METHODS = ['Corporate Card', 'Personal Cash'].freeze
  DEFAULT_PAYMENT_METHOD = 'Corporate Card'

  def image_path
    self.image_url
  end
end
