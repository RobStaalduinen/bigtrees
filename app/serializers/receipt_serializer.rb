# frozen_string_literal: true

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
class ReceiptSerializer < ApplicationSerializer
  attribute :date
  attribute :category
  attribute :job
  attribute :payment_method
  attribute :description
  attribute :cost
  attribute :state
  attribute :rejection_reason

  attribute :image_path

  # Associations
  belongs_to :arborist
end
