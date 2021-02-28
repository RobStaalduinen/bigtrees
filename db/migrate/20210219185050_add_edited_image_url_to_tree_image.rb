class AddEditedImageUrlToTreeImage < ActiveRecord::Migration
  def change
    add_column :tree_images, :edited_image_url, :string
  end
end
