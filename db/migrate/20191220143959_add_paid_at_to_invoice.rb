class AddPaidAtToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :paid_at, :date
  end
end
