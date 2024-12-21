class AddApprovedToReceipts < ActiveRecord::Migration[5.2]
  def change
    add_column :receipts, :approved, :boolean, default: false

    Receipt.all.update_all(approved: true)
  end
end
