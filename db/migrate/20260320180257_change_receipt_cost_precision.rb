class ChangeReceiptCostPrecision < ActiveRecord::Migration[6.0]
  def change
    change_column :receipts, :cost, :decimal, precision: 10, scale: 2
  end
end
