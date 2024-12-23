class AddInvoiceNumberToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :invoice_number, :integer
  end
end
