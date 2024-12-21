class ChangeTreeImageRelationship < ActiveRecord::Migration[5.2]
  def change
    remove_column :tree_images, :estimate_id, :integer
    remove_column :tree_images, :tree_number, :integer
  end
end
