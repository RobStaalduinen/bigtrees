class AddRejectionReasonToReceipt < ActiveRecord::Migration
  def change
    add_column :receipts, :rejection_reason, :string
  end
end
