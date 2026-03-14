# == Schema Information
#
# Table name: payouts
#
#  id         :integer          not null, primary key
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Payout < ActiveRecord::Base
  has_many :work_records, dependent: :nullify

end
