class AddVehicleToReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :receipts, :vehicle_id, :integer
  end
end
