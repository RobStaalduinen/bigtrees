class WorkRecord < ActiveRecord::Base
  belongs_to :arborist

  scope :for_month, ->(date) { where("date >= ? AND date <= ?", date.beginning_of_month, date.end_of_month).order("date ASC") }

  scope :by_date, -> { order('date ASC').group_by { |w| w.date }.sort_by{ |date, _| date } }
  scope :by_week, -> { order('date ASC').group_by { |w| w.week_number }.sort_by{ |week, _| week } }
  scope :by_month, -> { order('date ASC').group_by { |w| w.date.strftime("%m - %B") }.sort_by{ |month, _| month } }
  scope :by_year, -> { order('date ASC').group_by { |w| w.date.strftime("%Y") }.sort_by{ |year, _| year } }

  def week_number
    self.date.end_of_week
  end

  validates :date, presence: true
  validates :hours, presence: true
end
