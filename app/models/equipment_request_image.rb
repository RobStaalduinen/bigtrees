# == Schema Information
#
# Table name: equipment_request_images
#
#  id                   :integer          not null, primary key
#  equipment_request_id :integer          not null
#  image_url            :string(255)      not null
#  position             :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class EquipmentRequestImage < ActiveRecord::Base
  belongs_to :equipment_request

  validates :image_url, presence: true

  def file_name
    image_url.gsub('%2F', '/').split('/').last
  end
end
