class AddDetailsToJob < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :arborist_id, :integer, index: true

    create_table :job_assignments do |t|
      t.belongs_to :job, null: false
      t.belongs_to :arborist, null: false

      t.timestamps
    end
  end
end
