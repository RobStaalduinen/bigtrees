class AddFileUrlToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :url, :string
  end
end
