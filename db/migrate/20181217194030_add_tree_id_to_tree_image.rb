class AddTreeIdToTreeImage < ActiveRecord::Migration
  def change
    add_column :tree_images, :tree_id, :integer, index: true
  end
end
