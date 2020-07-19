class AddInvoiceNumberToEstimate < ActiveRecord::Migration
  def change
    add_column :estimates, :invoice_number, :integer
  end
end
