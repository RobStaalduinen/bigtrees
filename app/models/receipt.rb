# == Schema Information
#
# Table name: receipts
#
#  id                 :integer          not null, primary key
#  arborist_id        :integer
#  date               :date
#  category           :string(255)
#  job                :string(255)
#  payment_method     :string(255)
#  description        :string(255)
#  cost               :decimal(10, )
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#  vehicle_id         :integer
#  approved           :boolean          default(FALSE)
#  image_url          :string(255)
#  state              :string(255)      default("pending")
#  rejection_reason   :string(255)
#  organization_id    :integer
#
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
