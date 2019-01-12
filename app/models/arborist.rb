class Arborist < ActiveRecord::Base
  has_many :estimates

  before_create :set_session_token

  def set_session_token
    self.session_token = SecureRandom.hex
  end

  scope :real, -> { } # where.not(email: "rob.staalduinen@gmail.com") }
end
