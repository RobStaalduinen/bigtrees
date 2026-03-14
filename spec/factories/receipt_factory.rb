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
FactoryBot.define do
  factory :receipt do
    association       :arborist
    date              { Date.today }
    category          { 'Fuel' }
    job               { 'Big Trees' }
    payment_method    { 'Corporate Card' }
    cost              { 100.0 }
    approved          { false }
  end
end
