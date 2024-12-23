class AddPaperclipAttachmentToTreeImage < ActiveRecord::Migration[5.2]
  def change
    remove_column :tree_images, :filename
    add_attachment :tree_images, :asset
  end
end
