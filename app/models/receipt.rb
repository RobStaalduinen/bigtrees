class Receipt < ActiveRecord::Base
  belongs_to :arborist
  belongs_to :vehicle
  
  has_attached_file :photo

  CATEGORIES = ['Fuel', 'Tools', 'Repairs', 'Travel', 'Other'].freeze
  DEFAULT_CATEGORY = 'Fuel'
  JOBS = ['Big Trees', 'Big Properties', 'Big Stumps'].freeze
  DEFAULT_JOB = 'Big Trees'
  PAYMENT_METHODS = ['Corporate Card', 'Personal Cash'].freeze
  DEFAULT_PAYMENT_METHOD = 'Corporate Card'

  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
