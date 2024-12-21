class AddMechanicIdToEquipmentRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :equipment_requests, :mechanic_id, :integer, index: true
  end
end
