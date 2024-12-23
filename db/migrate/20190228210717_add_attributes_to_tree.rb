class AddAttributesToTree < ActiveRecord::Migration[5.2]
  def change
    add_column :trees, :description, :string
    add_column :trees, :stump_removal, :boolean
  end
end
