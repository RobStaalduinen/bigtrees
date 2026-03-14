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
FactoryBot.define do
  factory :equipment_request do
    association             :vehicle
    category                { 'other' }
    description             { 'Test request' }
    state                   { 'submitted' }
  end
end
