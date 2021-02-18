class AddImageSmallUrlToTreeImage < ActiveRecord::Migration
  def change
    add_column :tree_images, :image_small_url, :string
  end
end
