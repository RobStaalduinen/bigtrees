class AddImageUrlToTree < ActiveRecord::Migration
  def change
    add_column :tree_images, :image_url, :string
  end
end
