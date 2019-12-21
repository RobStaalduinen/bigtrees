class AddPaidAtToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :paid_at, :date
  end
end
