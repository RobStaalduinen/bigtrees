class Payout < ActiveRecord::Base
  has_many :work_records, dependent: :nullify

end
