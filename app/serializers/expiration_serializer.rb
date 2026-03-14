# == Schema Information
#
# Table name: expirations
#
#  id         :integer          not null, primary key
#  vehicle_id :integer
#  name       :string(255)
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ExpirationSerializer < ApplicationSerializer
  attribute :name
  attribute :date
end
