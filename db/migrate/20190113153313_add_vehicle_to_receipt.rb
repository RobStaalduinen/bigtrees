class AddVehicleToReceipt < ActiveRecord::Migration
  def change
    add_column :receipts, :vehicle_id, :integer
  end
end
