class AddAdditionalHoursFields < ActiveRecord::Migration[5.2]
  def change
    add_column :work_records, :start_at, :time
    add_column :work_records, :end_at, :time
    add_column :work_records, :unpaid_hours, :float
    add_column :work_records, :hourly_rate, :float
    add_column :arborists, :hourly_rate, :float
  end
end
