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
