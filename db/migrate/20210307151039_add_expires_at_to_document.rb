class AddExpiresAtToDocument < ActiveRecord::Migration
  def change
    add_column :documents, :expires_at, :date
  end
end
