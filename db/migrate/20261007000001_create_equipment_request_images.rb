class CreateEquipmentRequestImages < ActiveRecord::Migration[8.0]
  # Repair requests used to hold a single image in equipment_requests.image_url.
  # They now have many images; existing single images are copied across so
  # nothing disappears. The legacy column is left in place (unused) so this can
  # be rolled back safely; drop it in a later migration.
  def up
    create_table :equipment_request_images, id: :integer do |t|
      t.integer :equipment_request_id, null: false
      t.string  :image_url, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :equipment_request_images, :equipment_request_id

    execute <<~SQL
      INSERT INTO equipment_request_images (equipment_request_id, image_url, position, created_at, updated_at)
      SELECT id, image_url, 0, created_at, updated_at
      FROM equipment_requests
      WHERE image_url IS NOT NULL AND image_url <> ''
    SQL
  end

  def down
    drop_table :equipment_request_images
  end
end
