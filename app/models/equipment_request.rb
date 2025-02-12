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
  belongs_to :vehicle
  belongs_to :mechanic, class_name: 'Arborist'

  CATEGORIES = %w[other mechanical equipment supplies paperwork].freeze

  def image_path
    image_url
  end

  def file_name
    image_path.gsub('%2F', '/').split('/').last
  end

  validates :category, inclusion: { in: CATEGORIES }, presence: true
  validates :description, presence: true
end
