class AddEstimatToTreeImages < ActiveRecord::Migration[5.2]
  def self.up
    add_column :tree_images, :estimate_id, :integer, index: true

    TreeImage.find_each do |tree_image|
      next unless tree_image&.tree&.estimate_id

      tree_image.update(estimate_id: tree_image.tree.estimate_id)
    end
  end

  def self.down
    remove_column :tree_images, :estimate_id
  end
end
