class Receipt < ActiveRecord::Base
  belongs_to :arborist
  belongs_to :vehicle

  has_attached_file :photo

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

  # validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  def image_path
    self.image_url || self.photo.url
  end
end
