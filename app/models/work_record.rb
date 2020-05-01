class WorkRecord < ActiveRecord::Base
  belongs_to :arborist
  belongs_to :payout

  before_save :set_hourly_rate

  scope :for_month, ->(date) { where("date >= ? AND date <= ?", date.beginning_of_month, date.end_of_month).order("date ASC") }

  scope :by_date, -> { order('date ASC').group_by { |w| w.date }.sort_by{ |date, _| date } }
  scope :by_week, -> { order('date ASC').group_by { |w| w.week_number }.sort_by{ |week, _| week } }
  scope :by_month, -> { order('date ASC').group_by { |w| w.date.strftime("%m - %B") }.sort_by{ |month, _| month } }
  scope :by_year, -> { order('date ASC').group_by { |w| w.date.strftime("%Y") }.sort_by{ |year, _| year } }
  scope :unpaid, -> { where(payout: nil) }
  scope :before, -> (end_at) { where("date <= ?", end_at) }

  def week_number
    self.date.end_of_week
  end

  def set_hourly_rate
    self.hourly_rate = self.arborist.hourly_rate
  end

  def range_string
    start_string = self.start_at.strftime("%l:%M") rescue "?"
    end_string = self.end_at.strftime("%l:%M") rescue "?"
    "#{start_string} - #{end_string}"
  end

  def earnings
    self.hourly_rate.present? ? (self.hours * self.hourly_rate) : 0.0
  end

  validates :date, presence: true
  validates :hours, presence: true
end
