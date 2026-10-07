# == Schema Information
#
# Table name: equipment_requests
#
#  id                 :integer          not null, primary key
#  arborist_id        :integer
#  vehicle_id         :integer
#  submitted_at       :date
#  category           :string(255)
#  description        :text(65535)
#  state              :string(255)      default("submitted")
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_url          :string(255)
#  resolver_id        :integer
#  resolution_notes   :string(255)
#  mechanic_id        :integer
#  organization_id    :integer
#
class EquipmentRequest < ActiveRecord::Base
  include AASM

  aasm(column: :state) do
    state :submitted, initial: true
    state :assigned
    state :resolved

    event :resolve do
      transitions from: [:submitted, :assigned], to: :resolved
    end

    event :assign do
      transitions from: :submitted, to: :assigned
      transitions from: :assigned, to: :assigned
    end
  end

  belongs_to :organization
  belongs_to :arborist
  belongs_to :vehicle, optional: true
  belongs_to :mechanic, class_name: 'Arborist', optional: true

  has_many :images,
           -> { order(:position, :id) },
           class_name: 'EquipmentRequestImage',
           dependent: :destroy,
           autosave: true

  CATEGORIES = %w[other mechanical equipment supplies paperwork].freeze

  def image_urls
    images.map(&:image_url)
  end

  # Replaces the request's images with exactly these URLs, in this order.
  # Existing images whose URL is kept are reused rather than recreated.
  def image_urls=(urls)
    urls = Array(urls).map(&:to_s).reject(&:blank?).uniq
    existing = images.index_by(&:image_url)

    self.images = urls.each_with_index.map do |url, position|
      image = existing[url] || EquipmentRequestImage.new(image_url: url)
      image.position = position
      image
    end
  end

  validates :category, inclusion: { in: CATEGORIES }, presence: true
  validates :description, presence: true
end
