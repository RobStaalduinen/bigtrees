class WorkRecord < ActiveRecord::Base
  belongs_to :arborist

  scope :for_month, ->(date) { where("date >= ? AND date <= ?", date.beginning_of_month, date.end_of_month).order("date ASC") }

  def week_number
    self.date.strftime("%Y") + ' | ' + "Week " + (self.date.strftime("%U").to_i + 1).to_s
  end

  validates :date, presence: true
  validates :hours, presence: true
end
