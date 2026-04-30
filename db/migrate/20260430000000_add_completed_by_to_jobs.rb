class AddCompletedByToJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :completed_by_id, :integer
    add_index :jobs, :completed_by_id
  end
end
