class AddClientUploadIdToTreeImages < ActiveRecord::Migration[6.0]
  def change
    add_column :tree_images, :client_upload_id, :string
    # Client-generated UUID; uniqueness is global. Multiple NULLs are allowed
    # (legacy rows have none), which a MySQL/SQLite unique index permits.
    add_index :tree_images, :client_upload_id, unique: true
  end
end
