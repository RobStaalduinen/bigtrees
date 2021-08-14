class AddWorkEndDateToEstimates < ActiveRecord::Migration
  def change
    rename_column :estimates, :work_date, :work_start_date

    add_column :estimates, :work_end_date, :date

    Estimate.where.not(work_start_date: nil).each do |e|
      e.work_end_date = e.work_start_date
      e.save
    end
  end
end
