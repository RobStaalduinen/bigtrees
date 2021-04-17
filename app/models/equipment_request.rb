class EquipmentRequest < ActiveRecord::Base
  include AASM

  aasm(column: :state) do
    state :submitted, initial: true
    state :resolved

    event :resolve do
      transitions from: :submitted, to: :resolved
    end
  end

  belongs_to :arborist
  belongs_to :vehicle

  has_attached_file :image

  CATEGORIES = %w[other mechanical equipment supplies paperwork].freeze

  def image_path
    image.present? ? image.url : image_url
  end

  def file_name
    image_path.gsub('%2F', '/').split('/').last
  end

  validates :category, inclusion: { in: CATEGORIES }, presence: true
  validates :description, presence: true
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
