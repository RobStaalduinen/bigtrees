class AddFinalInvoiceSentAtToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :estimates, :final_invoice_sent_at, :date
  end
end
