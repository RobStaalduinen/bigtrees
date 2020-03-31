class Vehicle < ActiveRecord::Base
  has_many :receipts
  has_many :equipment_requests
  has_many :expirations
end
