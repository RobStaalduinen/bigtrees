class CreateWorkRecords < ActiveRecord::Migration
  def change
    create_table :work_records do |t|
      t.belongs_to :arborist, index: true
      t.date :date
      t.float :hours
    end
  end
end
