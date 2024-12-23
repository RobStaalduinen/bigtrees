class AddImageSmallUrlToTreeImage < ActiveRecord::Migration[5.2]
  def change
    add_column :tree_images, :image_small_url, :string
  end
end
