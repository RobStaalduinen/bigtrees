class AddRejectionReasonToReceipt < ActiveRecord::Migration[5.2]
  def change
    add_column :receipts, :rejection_reason, :string
  end
end
