class CreateNewEstimateTable < ActiveRecord::Migration
  def change
    drop_table :estimates

    create_table :estimates do |t|

      t.integer :tree_quantity, default: 1
      
      t.string :person_name
      t.string :street
      t.string :city
      t.string :phone
      t.string :email

      t.boolean :stump_removal, default: false
      t.boolean :vehicle_access, default: false
      t.boolean :breakables, default: false
      t.boolean :wood_removal, default: false

      t.integer :status, null: false, default: 0

      t.timestamps null: false
    end
  end
end
