class AddSkipScheduleToEstimate < ActiveRecord::Migration
  def change
    add_column :estimates, :skip_schedule, :boolean
  end
end
