class AddSkipScheduleToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :skip_schedule, :boolean
  end
end
