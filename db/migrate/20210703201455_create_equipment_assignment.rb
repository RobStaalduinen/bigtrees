class CreateEquipmentAssignment < ActiveRecord::Migration[5.2]
  def change
    create_table :equipment_assignments do |t|
      t.belongs_to :estimate
      t.belongs_to :vehicle

      t.timestamps null: false
    end
  end
end
