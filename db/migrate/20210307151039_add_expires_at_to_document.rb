class AddExpiresAtToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :expires_at, :date
  end
end
