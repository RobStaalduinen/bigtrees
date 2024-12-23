class AddImageUrlToReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :receipts, :image_url, :string
  end
end
