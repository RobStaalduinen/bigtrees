class AddFieldsToEquipmentRequest < ActiveRecord::Migration
  def change
    add_column :equipment_requests, :image_url, :string
    add_column :equipment_requests, :resolver_id, :integer
    add_column :equipment_requests, :resolution_notes, :string

    add_index :equipment_requests, :resolver_id
  end
end
