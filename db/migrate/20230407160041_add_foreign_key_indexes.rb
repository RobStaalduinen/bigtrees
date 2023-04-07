class AddForeignKeyIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :customer_details, :estimate_id

    add_index :estimates, :submission_completed
    add_index :estimates, :cancelled_at
    add_index :estimates, :arborist_id
    add_index :estimates, :customer_id
  end
end
