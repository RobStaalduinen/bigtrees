class AddEditedImageUrlToTreeImage < ActiveRecord::Migration[5.2]
  def change
    add_column :tree_images, :edited_image_url, :string
  end
end
