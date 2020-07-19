class CreateTree < ActiveRecord::Migration
  def change
    create_table :trees do |t|
      t.belongs_to :estimate, index: true
      t.integer :work_type, default: 0
      t.integer :sequence, default: 0
      t.decimal :cost
    end
  end
end
