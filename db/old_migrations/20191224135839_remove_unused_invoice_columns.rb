class RemoveUnusedInvoiceColumns < ActiveRecord::Migration
  def change
    remove_column :estimates, :invoice_number
    remove_column :estimates, :discount_applied
    remove_column :estimates, :payment_method
    remove_column :estimates, :final_invoice_sent_at
  end
end
