class AddImageUrlToTree < ActiveRecord::Migration[5.2]
  def change
    add_column :tree_images, :image_url, :string
  end
end
