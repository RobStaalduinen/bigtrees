class Arborist < ActiveRecord::Base
  has_secure_password

  has_many :estimates
  has_many :receipts
  has_many :work_records
  has_many :documents

  before_create :set_session_token

  def set_session_token
    self.session_token = SecureRandom.hex
  end

  def get_receipts
    self.admin ? Receipt.all : self.receipts
  end

  def recent_work
    {
      this_month: self.work_records.for_month(Date.today),
      last_month: self.work_records.for_month(Date.today - 1.month)
    }
  end

  scope :real, -> { where.not(hidden: true) }
  scope :active, -> { where(active: true) }

  validates :name, presence: true
end
