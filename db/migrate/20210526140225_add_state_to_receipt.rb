class AddStateToReceipt < ActiveRecord::Migration
  def change
    add_column :receipts, :state, :string
    add_index :receipts, :state

    Receipt.all.each do |receipt|
      receipt.state = 'approved' if receipt.approved
      receipt.state = 'pending' if !receipt.approved
      receipt.save
    end
  end
end
