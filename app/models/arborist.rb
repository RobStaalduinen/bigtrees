class Arborist < ActiveRecord::Base
  has_secure_password

  has_many :estimates
  has_many :receipts

  before_create :set_session_token

  def set_session_token
    self.session_token = SecureRandom.hex
  end

  def get_receipts
    self.is_admin ? Receipt.all : self.receipts
  end

  scope :real, -> { } # where.not(email: "rob.staalduinen@gmail.com") }
end
