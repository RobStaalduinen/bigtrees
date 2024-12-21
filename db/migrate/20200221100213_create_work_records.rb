class CreateWorkRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :work_records do |t|
      t.belongs_to :arborist, index: true
      t.date :date
      t.float :hours
    end
  end
end
