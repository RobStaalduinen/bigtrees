class AddOrganizationAssociations < ActiveRecord::Migration[5.2]
  def change
    add_column :receipts, :organization_id, :integer, index: true
    add_column :equipment_requests, :organization_id, :integer, index: true

    Receipt.update_all(organization_id: 1)
    EquipmentRequest.update_all(organization_id: 1)
  end
end
