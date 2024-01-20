class AddOrganizationToVehicles < ActiveRecord::Migration[5.2]
  def change
    add_column :vehicles, :organization_id, :integer

    Vehicle.update_all(organization_id: 1)
  end
end
