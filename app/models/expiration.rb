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
class Expiration < ActiveRecord::Base
  belongs_to :vehicle
  NAMES = ['Annual Sticker', 'Plate Sticker']

  def soon?  
    (self.date - Date.today).days.to_i < 30.days.to_i
  end

  def expired?
    self.date < Date.today
  end

  def display_color
    return 'red' if self.expired?
    return 'orange' if self.soon?
    return 'black'
  end

  validates :name, presence: true, inclusion: { in: NAMES }
  validates :date, presence: true
end
