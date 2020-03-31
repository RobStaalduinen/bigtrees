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
