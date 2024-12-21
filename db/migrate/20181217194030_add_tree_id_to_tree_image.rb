class AddTreeIdToTreeImage < ActiveRecord::Migration[5.2]
  def change
    add_column :tree_images, :tree_id, :integer, index: true
  end
end
