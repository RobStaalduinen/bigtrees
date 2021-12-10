class Vehicle < ActiveRecord::Base
  has_many :receipts
  has_many :equipment_requests
  has_many :expirations
  has_many :equipment_assignments, dependent: :destroy
end
