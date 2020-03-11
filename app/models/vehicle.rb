class Vehicle < ActiveRecord::Base
  has_many :receipts
  has_many :equipment_requests
end
