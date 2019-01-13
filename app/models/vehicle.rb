class Vehicle < ActiveRecord::Base
  has_many :receipts
end
