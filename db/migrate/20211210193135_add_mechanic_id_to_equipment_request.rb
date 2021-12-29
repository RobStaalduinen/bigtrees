class AddMechanicIdToEquipmentRequest < ActiveRecord::Migration
  def change
    add_column :equipment_requests, :mechanic_id, :integer, index: true
  end
end
