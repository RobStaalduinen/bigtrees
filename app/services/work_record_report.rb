# frozen_string_literal

class WorkRecordReport
  def initialize(work_records)
    @work_records = work_records
  end

  def report_by_date
    report = {}

    @work_records.order('date DESC').group_by { |w| w.date }.each do |date, work_records|
      report[date] = work_records.sort_by {|w| w.date }.reverse.map do |record|
        {
          id: record.id,
          arborist: record.arborist.name,
          start_at: record.start_at&.strftime('%H:%M:%S'),
          end_at: record.end_at&.strftime('%H:%M:%S'),
          hours: record.hours,
          unpaid_hours: record.unpaid_hours
        }
      end
    end

    report
  end

  def summary_report
    @work_records.map do |date, records|
      entry = { 
        date: date,
        total: records.map { |r| r.hours }.sum,
        hours: {}
      }
    
      entry[:hours] = records.group_by{ |r| r.arborist.name }.map do |arborist_name, records|
        {
          name: arborist_name,
          hours: records.map { |r| r.hours }.sum
        }
      end
      entry
    end
  end
end